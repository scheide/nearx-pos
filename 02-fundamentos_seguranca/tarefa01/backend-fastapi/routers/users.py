from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr, validator
import bcrypt
import hashlib
import requests
from db import db

router = APIRouter()


class UserCreate(BaseModel):
    email: EmailStr
    password: str

    @validator('password')
    def validate_password(cls, v, values):
        email = values.get("email", "")
        if email and email.split("@")[0].lower() in v.lower():
            raise ValueError("Senha não pode conter parte do e-mail.")
        if len(v) < 8:
            raise ValueError("Senha deve ter pelo menos 8 caracteres.")
        if len(v) > 64:
            raise ValueError("Senha muito longa.")
        return v


def is_pwned(password: str) -> bool:
    sha1 = hashlib.sha1(password.encode('utf-8')).hexdigest().upper()
    prefix = sha1[:5]
    suffix = sha1[5:]
    res = requests.get(f"https://api.pwnedpasswords.com/range/{prefix}")
    return suffix in res.text


@router.post("/register")
async def register(user: UserCreate):
    if await db.users.find_one({"email": user.email}):
        raise HTTPException(status_code=400, detail="Email já cadastrado.")

    if is_pwned(user.password):
        raise HTTPException(
            status_code=400, detail="Senha já vazou. Escolha outra.")

    hashed_pw = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())
    await db.users.insert_one({
        "email": user.email,
        "password": hashed_pw.decode()
    })

    return {"message": "Usuário registrado com sucesso"}
