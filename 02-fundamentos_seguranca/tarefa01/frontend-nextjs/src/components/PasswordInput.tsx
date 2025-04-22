"use client";
import { useState } from "react";
import zxcvbn from "zxcvbn";

export default function PasswordInput({
  value,
  onChange,
}: {
  value: string;
  onChange: (val: string) => void;
}) {
  const [isPasswordVisible, setIsPasswordVisible] = useState(false);
  const result = zxcvbn(value);
  const strength = result.score;
  const strengthLabel = ["Muito fraca", "Fraca", "Razoável", "Boa", "Forte"];

  const togglePasswordVisibility = () => {
    setIsPasswordVisible((prev) => !prev);
  };

  return (
    <div>
      <label className="block text-sm font-medium">Senha</label>
      <div className="relative">
        <input
          type={isPasswordVisible ? "text" : "password"}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className="w-full p-2 border rounded mt-1 pr-10"
        />
        <button
          type="button"
          onClick={togglePasswordVisibility}
          className="absolute inset-y-0 right-0 flex items-center pr-3 text-gray-500"
        >
          {isPasswordVisible ? "🙈" : "👁️"}
        </button>
      </div>
      <div className="mt-2 h-2 bg-gray-200 rounded">
        <div
          className="h-2 rounded transition-all"
          style={{
            width: `${(strength + 1) * 20}%`,
            backgroundColor: [
              "#e74c3c",
              "#e67e22",
              "#f1c40f",
              "#2ecc71",
              "#27ae60",
            ][strength],
          }}
        />
      </div>
      <p className="text-xs mt-1">{strengthLabel[strength]}</p>
    </div>
  );
}
