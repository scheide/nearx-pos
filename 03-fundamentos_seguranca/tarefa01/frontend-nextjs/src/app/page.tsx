"use client";

import { useState } from "react";
import PasswordInput from "@/components/PasswordInput";
import axios from "axios";

export default function RegisterPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");

  const handleRegister = async () => {
    try {
      const res = await axios.post("http://localhost:8000/register", {
        email,
        password,
      });
      setMessage(res.data.message);
    } catch (err: any) {
      setMessage(err.response?.data?.detail || "Erro ao registrar.");
    }
  };

  return (
    <div className="max-w-md mx-auto mt-10 p-6 border rounded-xl shadow">
      <h1 className="text-2xl font-bold mb-4">Criar Conta</h1>
      <label className="block mb-2">Email</label>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        className="w-full p-2 border rounded mb-4"
      />
      <PasswordInput value={password} onChange={setPassword} />
      <button
        onClick={handleRegister}
        className="w-full mt-4 bg-blue-600 text-white p-2 rounded hover:bg-blue-700"
      >
        Registrar
      </button>
      {message && <p className="mt-4 text-sm text-center">{message}</p>}
    </div>
  );
}
