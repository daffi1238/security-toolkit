# Análisis de Scope — [PROGRAM]

**Plataforma:** HackerOne / Bugcrowd / Intigriti / Privado
**URL del programa:** [URL]
**Fecha inicio:** [YYYY-MM-DD]

---

## In Scope

| Asset | Tipo | Notas |
|-------|------|-------|
| *.target.com | Wildcard domain | |
| api.target.com | Subdomain | API v2 en /api/v2/ |
| 10.0.0.0/24 | IP range | Solo desde VPN del programa |

## Out of Scope

| Asset | Razón |
|-------|-------|
| blog.target.com | Hosted en WordPress.com |
| status.target.com | Third-party (Statuspage) |

---

## Restricciones

- [ ] Rate limiting: [X req/min si se menciona]
- [ ] Automated scanning permitido: Sí / No / Con restricciones
- [ ] Crear cuentas de prueba: Sí / No (contactar soporte)
- [ ] Afectar a usuarios reales: Nunca
- [ ] Social engineering: No
- [ ] DoS/DDoS: No
- [ ] Physical attacks: No

---

## Premios (Bounty Table)

| Severidad | Mínimo | Máximo |
|-----------|--------|--------|
| Critical | $X | $X |
| High | $X | $X |
| Medium | $X | $X |
| Low | $X | $X |

---

## Tecnologías Identificadas

| Asset | Tecnologías | Versión | CVEs conocidos |
|-------|------------|---------|----------------|
| | | | |

---

## Superficie Interesante

- [ ] Login / OAuth / SSO
- [ ] File upload
- [ ] Payment flow
- [ ] API pública
- [ ] Admin panel
- [ ] Exportación de datos
- [ ] Webhooks
- [ ] Email templates
- [ ] 2FA flow
- [ ] Password reset
