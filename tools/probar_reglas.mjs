// Comprueba que las reglas dejan tocar lo propio y niegan lo ajeno.
// Uso (con los emuladores arrancados y los datos cargados):
//   node probar_reglas.mjs TU_PROJECT_ID
// Entra como Ana e intenta editar y borrar mensajes de Luis (semilla-02).
// No modifica nada: la edición propia reescribe el mismo texto y
// el borrado solo se intenta sobre un mensaje ajeno.

const proyecto = process.argv[2];
if (!proyecto) {
  console.error('Falta el id del proyecto: node probar_reglas.mjs TU_PROJECT_ID');
  process.exit(1);
}

const AUTH = process.env.AUTH_URL ?? 'http://127.0.0.1:9099';
const FS = process.env.FIRESTORE_URL ?? 'http://127.0.0.1:8080';
const base = `${FS}/v1/projects/${proyecto}/databases/(default)/documents/mensajes`;

const login = await fetch(
  `${AUTH}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=falsa`,
  {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: 'ana@prueba.com',
      password: '123456',
      returnSecureToken: true,
    }),
  },
);
if (!login.ok) {
  console.error('No se pudo entrar como Ana. ¿Cargaste los datos con seed.mjs?');
  process.exit(1);
}
const { idToken } = await login.json();
const cabeceras = {
  'Content-Type': 'application/json',
  Authorization: `Bearer ${idToken}`,
};

async function probar(descripcion, esperado, url, opciones) {
  const r = await fetch(url, { headers: cabeceras, ...opciones });
  const resultado = r.status === esperado ? 'OK ' : 'MAL';
  console.log(`${resultado} ${descripcion}: HTTP ${r.status} (esperado ${esperado})`);
  return r.status === esperado;
}

const textoPropio = '¿alguien ha terminado ya la Fase 1?';
const resultados = [
  await probar('Editar un mensaje propio (semilla-01)', 200,
    `${base}/semilla-01?updateMask.fieldPaths=texto`,
    { method: 'PATCH', body: JSON.stringify({ fields: { texto: { stringValue: `Buenos días, ${textoPropio}` } } }) }),
  await probar('Editar un mensaje ajeno (semilla-02)', 403,
    `${base}/semilla-02?updateMask.fieldPaths=texto`,
    { method: 'PATCH', body: JSON.stringify({ fields: { texto: { stringValue: 'Texto cambiado por Ana' } } }) }),
  await probar('Borrar un mensaje ajeno (semilla-02)', 403,
    `${base}/semilla-02`,
    { method: 'DELETE' }),
];
process.exit(resultados.every(Boolean) ? 0 : 1);
