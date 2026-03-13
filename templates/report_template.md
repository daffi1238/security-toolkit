# [VULN_TYPE] — [FEATURE/ENDPOINT] — [IMPACT_SUMMARY]

**Programa:** [Program Name]
**Fecha:** [YYYY-MM-DD]
**Severidad:** Critical / High / Medium / Low / Informational
**CVSS:** [score] — [vector string]
**CWE:** CWE-[number]: [name]

---

## Descripción

[Descripción clara del problema. Qué existe, por qué es un problema, contexto necesario.]

---

## Impacto

[Qué puede hacer un atacante real. Concreto y específico.]

**Ejemplo:**
> Un atacante autenticado como usuario estándar puede acceder a los datos personales (nombre, email, teléfono, dirección) de cualquier otro usuario registrado en la plataforma simplemente modificando el parámetro `user_id` en la petición.

---

## Pasos para Reproducir

**Pre-requisitos:**
- Cuenta de prueba: user_a@example.com (victim)
- Cuenta atacante: user_b@example.com (attacker)

**Pasos:**

1. Autenticarse como `user_b`
2. Navegar a [URL]
3. Interceptar con Burp Suite la petición:
   ```http
   GET /api/v1/users/[USER_B_ID] HTTP/1.1
   Host: target.com
   Authorization: Bearer [TOKEN_B]
   ```
4. Modificar `[USER_B_ID]` por `[USER_A_ID]`
5. Enviar la petición

---

## Prueba de Concepto

### Request
```http
GET /api/v1/users/12345 HTTP/1.1
Host: target.com
Authorization: Bearer eyJ...
```

### Response
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": 12345,
  "email": "victim@example.com",
  "name": "Victim User",
  "phone": "+34 600 000 000"
}
```

---

## Remediación

[Recomendación concreta.]

**Ejemplo:**
> Implementar autorización a nivel de objeto en el endpoint `/api/v1/users/{id}`. El servidor debe verificar que el `user_id` de la sesión activa coincide con el `id` solicitado, o que el usuario tiene un rol con permisos explícitos para acceder a recursos de otros usuarios.

---

## Referencias

- [OWASP API Security Top 10 — API1:2023 Broken Object Level Authorization](https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/)
- [CWE-284: Improper Access Control](https://cwe.mitre.org/data/definitions/284.html)
