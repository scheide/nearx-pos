"use client";

import { useState } from "react";
import zxcvbn from "zxcvbn";

export default function ChangePasswordPage() {
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [strength, setStrength] = useState(0);
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  const handleChange = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // Simula usuário autenticado
    const user_id = "123456789";

    fetch("http://localhost:8000/change-password", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        user_id,
        current_password: currentPassword,
        new_password: newPassword,
      }),
    })
      .then(async (res) => {
        const data = await res.json();
        if (!res.ok) throw new Error(data.detail || "Erro ao trocar a senha");
        setMessage("Senha alterada com sucesso.");
      })
      .catch((err) => {
        setMessage(err.message);
      })
      .finally(() => setLoading(false));
  };

  const handlePasswordChange = (value: string) => {
    setNewPassword(value);
    const result = zxcvbn(value);
    setStrength(result.score);
  };

  return (
    <div className="max-w-md mx-auto mt-12 p-6 border rounded-2xl shadow">
      <h2 className="text-xl font-semibold mb-4">Trocar senha</h2>
      <form onSubmit={handleChange} className="space-y-4">
        <div>
          <label className="block text-sm font-medium mb-1">Senha atual</label>
          <input
            type="password"
            value={currentPassword}
            onChange={(e) => setCurrentPassword(e.target.value)}
            className="w-full px-3 py-2 border rounded-md"
            required
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Nova senha</label>
          <input
            type="password"
            value={newPassword}
            onChange={(e) => handlePasswordChange(e.target.value)}
            className="w-full px-3 py-2 border rounded-md"
            required
          />
          <div className="mt-1 text-sm text-gray-600">
            Força da senha:{" "}
            {["Muito fraca", "Fraca", "Ok", "Boa", "Forte"][strength]}
          </div>
        </div>
        <button
          type="submit"
          disabled={loading}
          className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? "Salvando..." : "Salvar nova senha"}
        </button>
      </form>
      {message && (
        <div className="mt-4 text-sm text-center text-red-600">{message}</div>
      )}
    </div>
  );
}
