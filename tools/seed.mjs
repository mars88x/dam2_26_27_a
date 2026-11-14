// Carga datos de prueba en los emuladores de Auth y Firestore.
// Uso (con los emuladores arrancados):  node seed.mjs TU_PROJECT_ID
// No necesita instalar nada: usa fetch (Node 18 o superior) y la API REST.
// Se puede repetir sin duplicar: los ids de los mensajes son fijos.

const proyecto = process.argv[2];
if (!proyecto) {
  console.error('Falta el id del proyecto: node seed.mjs TU_PROJECT_ID');
  process.exit(1);
}

const AUTH = process.env.AUTH_URL ?? 'http://127.0.0.1:9099';
const FS = process.env.FIRESTORE_URL ?? 'http://127.0.0.1:8080';
const CLAVE = '123456';

const usuarios = [
  { correo: 'ana@prueba.com', nombre: 'Ana', edad: 21 },
  { correo: 'luis@prueba.com', nombre: 'Luis', edad: 23 },
  { correo: 'marta@prueba.com', nombre: 'Marta', edad: 22 },
];

// [índice de usuario, texto, fecha]
const mensajes = [
  [0, 'Buenos días, ¿alguien ha terminado ya la Fase 1?', '2026-09-14T09:10:00Z'],
  [1, 'Yo acabo de subir el splash, me falta el onboarding.', '2026-09-14T09:40:00Z'],
  [2, 'Os paso mi guía de arranque por si os sirve.', '2026-09-20T17:05:00Z'],
  [0, 'Quedamos el jueves en la biblioteca para repasar.', '2026-09-24T12:30:00Z'],
  [1, 'Me apunto, llevo el portátil.', '2026-09-24T12:45:00Z'],
  [2, 'Yo llego un poco más tarde, empezad sin mí.', '2026-09-24T13:02:00Z'],
  [0, 'Se me ha roto Gradle otra vez, qué desastre.', '2026-10-01T08:15:00Z'],
  [1, 'Prueba con flutter clean y luego pub get.', '2026-10-01T08:22:00Z'],
  [0, 'Funcionó, gracias.', '2026-10-01T08:31:00Z'],
  [2, 'Ya tengo el login con los errores controlados.', '2026-10-06T19:20:00Z'],
  [1, 'Voy a probar en el emulador y en Chrome.', '2026-10-08T10:00:00Z'],
  [2, 'Cuidado con subir el google-services.json al repo.', '2026-10-09T11:11:00Z'],
  [0, 'Entregada la Fase 1, ahora toca la 1b.', '2026-10-18T11:30:00Z'],
  [1, 'Lo de las consultas con índice compuesto me suena a lío.', '2026-10-25T16:45:00Z'],
  [2, 'Es solo declararlo en firestore.indexes.json.', '2026-10-25T16:50:00Z'],
  [0, 'Mañana pruebo la paginación con startAfterDocument.', '2026-10-30T20:05:00Z'],
  [1, 'Alguien quiere ir a tomar algo después de clase?', '2026-11-02T14:00:00Z'],
  [2, 'Yo me apunto.', '2026-11-02T14:03:00Z'],
  [0, 'Hoy toca mapa y localización.', '2026-11-06T09:00:00Z'],
  [1, 'Con el GPS apagado la pantalla no se puede quedar colgada.', '2026-11-09T18:30:00Z'],
  [2, 'Ya sale mi posición en el mapa.', '2026-11-11T21:15:00Z'],
  [0, 'Último empujón antes de la entrega.', '2026-11-12T22:40:00Z'],
];

// Dónde estaba quien escribió cada mensaje (índice del mensaje -> [lat, lng]).
// Los que no aparecen no llevan posición. Son lugares de Madrid y alrededores.
const lugares = {
  0: [40.4168, -3.7038], // Puerta del Sol
  1: [40.4153, -3.6844], // Retiro
  2: [40.4167, -3.75], // Casa de Campo
  3: [40.4065, -3.6895], // Atocha
  5: [40.4725, -3.6823], // Chamartín
  6: [40.4818, -3.3635], // Alcalá de Henares
  8: [40.6326, -3.1667], // Guadalajara
  9: [40.3057, -3.7329], // Getafe
  10: [40.3272, -3.7635], // Leganés
  12: [40.5475, -3.642], // Alcobendas
  13: [40.4351, -3.8138], // Pozuelo
  15: [40.3601, -3.5167], // Rivas
  16: [40.4553, -3.4707], // Torrejón
  18: [40.0332, -3.6027], // Aranjuez
  19: [39.8628, -4.0273], // Toledo
  21: [40.9429, -4.1088], // Segovia
};

async function enviarJson(url, metodo, cuerpo, cabeceras = {}) {
  const r = await fetch(url, {
    method: metodo,
    headers: { 'Content-Type': 'application/json', ...cabeceras },
    body: JSON.stringify(cuerpo),
  });
  return { ok: r.ok, estado: r.status, json: await r.json().catch(() => ({})) };
}

// Crea el usuario; si ya existe, inicia sesión para obtener su uid.
async function obtenerUid(correo) {
  const cuerpo = { email: correo, password: CLAVE, returnSecureToken: true };
  const base = `${AUTH}/identitytoolkit.googleapis.com/v1/accounts`;
  let r = await enviarJson(`${base}:signUp?key=falsa`, 'POST', cuerpo);
  if (!r.ok) {
    r = await enviarJson(`${base}:signInWithPassword?key=falsa`, 'POST', cuerpo);
  }
  if (!r.ok) throw new Error(`No se pudo crear ni abrir a ${correo}: ${r.estado}`);
  return r.json.localId;
}

async function guardarDoc(ruta, campos) {
  const url = `${FS}/v1/projects/${proyecto}/databases/(default)/documents/${ruta}`;
  // "Bearer owner" salta las reglas en el emulador: es solo para cargar datos.
  const r = await enviarJson(url, 'PATCH', { fields: campos }, {
    Authorization: 'Bearer owner',
  });
  if (!r.ok) throw new Error(`Fallo al guardar ${ruta}: ${r.estado}`);
}

const texto = (v) => ({ stringValue: v });

try {
  const uids = [];
  for (const u of usuarios) {
    const uid = await obtenerUid(u.correo);
    uids.push(uid);
    await guardarDoc(`perfiles/${uid}`, {
      nombre: texto(u.nombre),
      edad: { integerValue: String(u.edad) },
    });
    console.log(`Usuario ${u.correo} -> ${uid}`);
  }
  for (let i = 0; i < mensajes.length; i++) {
    const [quien, t, fecha] = mensajes[i];
    const id = `semilla-${String(i + 1).padStart(2, '0')}`;
    const campos = {
      texto: texto(t),
      autor: texto(usuarios[quien].nombre),
      autorUid: texto(uids[quien]),
      fecha: { timestampValue: fecha },
    };
    if (lugares[i]) {
      campos.ubicacion = {
        geoPointValue: { latitude: lugares[i][0], longitude: lugares[i][1] },
      };
      campos.fechaUbicacion = { timestampValue: fecha };
    }
    await guardarDoc(`mensajes/${id}`, campos);
  }
  console.log(`Listo: ${usuarios.length} usuarios y ${mensajes.length} mensajes.`);
} catch (e) {
  console.error(e.message);
  console.error('¿Están arrancados los emuladores y es correcto el id del proyecto?');
  process.exit(1);
}
