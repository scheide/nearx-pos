# users.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field, validator
from passlib.hash import bcrypt
import hashlib
import requests

from db import db  # MongoDB connection

router = APIRouter()

# 🔐 Função para verificar se a senha foi vazada


def is_pwned(password: str) -> bool:
    sha1 = hashlib.sha1(password.encode('utf-8')).hexdigest().upper()
    prefix = sha1[:5]
    suffix = sha1[5:]
    res = requests.get(f"https://api.pwnedpasswords.com/range/{prefix}")
    return suffix in res.text

# 📦 Requisição esperada


class PasswordChangeRequest(BaseModel):
    user_id: str
    current_password: str
    new_password: str

    @validator('new_password')
    def validate_new_password(cls, v, values):
        if len(v) < 8:
            raise ValueError("A nova senha deve ter no mínimo 8 caracteres.")
        if len(v) > 64:
            raise ValueError("A nova senha deve ter no máximo 64 caracteres.")
        return v


@router.post("/change-password")
def change_password(data: PasswordChangeRequest):
    user = db.users.find_one({"_id": data.user_id})
    if not user:
        raise HTTPException(404, detail="Usuário não encontrado.")

    # Verifica a senha atual
    if not bcrypt.verify(data.current_password, user["password"]):
        raise HTTPException(400, detail="Senha atual incorreta.")

    # Impede reutilização
    if bcrypt.verify(data.new_password, user["password"]):
        raise HTTPException(
            400, detail="A nova senha não pode ser igual à anterior.")

    # Impede senhas com parte do e-mail
    email_username = user["email"].split("@")[0].lower()
    if email_username in data.new_password.lower():
        raise HTTPException(
            400, detail="A senha não pode conter parte do seu e-mail.")

    # Verifica senhas vazadas
    if is_pwned(data.new_password):
        raise HTTPException(
            400, detail="Esta senha já apareceu em vazamentos. Escolha outra.")

    # Tudo certo: atualiza a senha
    hashed = bcrypt.hash(data.new_password)
    db.users.update_one({"_id": data.user_id}, {"$set": {"password": hashed}})
    return {"message": "Senha alterada com sucesso."}
