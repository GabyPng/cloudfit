const { queryRef, executeQuery, mutationRef, executeMutation, validateArgs } = require('firebase/data-connect');

const EstadoTicket = {
  ABIERTO: "ABIERTO",
  EN_PROGRESO: "EN_PROGRESO",
  CERRADO: "CERRADO",
}
exports.EstadoTicket = EstadoTicket;

const Role = {
  ADMINISTRADOR: "ADMINISTRADOR",
  COACH: "COACH",
  NUTRIOLOGO: "NUTRIOLOGO",
  CLIENTE: "CLIENTE",
}
exports.Role = Role;

const connectorConfig = {
  connector: 'example',
  service: 'cloudfit-3c00a',
  location: 'us-east4'
};
exports.connectorConfig = connectorConfig;

const createUsuarioRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CreateUsuario', inputVars);
}
createUsuarioRef.operationName = 'CreateUsuario';
exports.createUsuarioRef = createUsuarioRef;

exports.createUsuario = function createUsuario(dcOrVars, vars) {
  return executeMutation(createUsuarioRef(dcOrVars, vars));
};

const crearPerfilRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearPerfil', inputVars);
}
crearPerfilRef.operationName = 'CrearPerfil';
exports.crearPerfilRef = crearPerfilRef;

exports.crearPerfil = function crearPerfil(dcOrVars, vars) {
  return executeMutation(crearPerfilRef(dcOrVars, vars));
};

const crearCoachRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearCoach', inputVars);
}
crearCoachRef.operationName = 'CrearCoach';
exports.crearCoachRef = crearCoachRef;

exports.crearCoach = function crearCoach(dcOrVars, vars) {
  return executeMutation(crearCoachRef(dcOrVars, vars));
};

const crearNutriologoRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearNutriologo', inputVars);
}
crearNutriologoRef.operationName = 'CrearNutriologo';
exports.crearNutriologoRef = crearNutriologoRef;

exports.crearNutriologo = function crearNutriologo(dcOrVars, vars) {
  return executeMutation(crearNutriologoRef(dcOrVars, vars));
};

const crearClienteRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearCliente', inputVars);
}
crearClienteRef.operationName = 'CrearCliente';
exports.crearClienteRef = crearClienteRef;

exports.crearCliente = function crearCliente(dcOrVars, vars) {
  return executeMutation(crearClienteRef(dcOrVars, vars));
};

const registrarProgresoRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'RegistrarProgreso', inputVars);
}
registrarProgresoRef.operationName = 'RegistrarProgreso';
exports.registrarProgresoRef = registrarProgresoRef;

exports.registrarProgreso = function registrarProgreso(dcOrVars, vars) {
  return executeMutation(registrarProgresoRef(dcOrVars, vars));
};

const crearEjercicioRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearEjercicio', inputVars);
}
crearEjercicioRef.operationName = 'CrearEjercicio';
exports.crearEjercicioRef = crearEjercicioRef;

exports.crearEjercicio = function crearEjercicio(dcOrVars, vars) {
  return executeMutation(crearEjercicioRef(dcOrVars, vars));
};

const crearRutinaRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearRutina', inputVars);
}
crearRutinaRef.operationName = 'CrearRutina';
exports.crearRutinaRef = crearRutinaRef;

exports.crearRutina = function crearRutina(dcOrVars, vars) {
  return executeMutation(crearRutinaRef(dcOrVars, vars));
};

const agregarEjercicioARutinaRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'AgregarEjercicioARutina', inputVars);
}
agregarEjercicioARutinaRef.operationName = 'AgregarEjercicioARutina';
exports.agregarEjercicioARutinaRef = agregarEjercicioARutinaRef;

exports.agregarEjercicioARutina = function agregarEjercicioARutina(dcOrVars, vars) {
  return executeMutation(agregarEjercicioARutinaRef(dcOrVars, vars));
};

const crearPlanNutricionalRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearPlanNutricional', inputVars);
}
crearPlanNutricionalRef.operationName = 'CrearPlanNutricional';
exports.crearPlanNutricionalRef = crearPlanNutricionalRef;

exports.crearPlanNutricional = function crearPlanNutricional(dcOrVars, vars) {
  return executeMutation(crearPlanNutricionalRef(dcOrVars, vars));
};

const crearTicketRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearTicket', inputVars);
}
crearTicketRef.operationName = 'CrearTicket';
exports.crearTicketRef = crearTicketRef;

exports.crearTicket = function crearTicket(dcOrVars, vars) {
  return executeMutation(crearTicketRef(dcOrVars, vars));
};

const responderTicketRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'ResponderTicket', inputVars);
}
responderTicketRef.operationName = 'ResponderTicket';
exports.responderTicketRef = responderTicketRef;

exports.responderTicket = function responderTicket(dcOrVars, vars) {
  return executeMutation(responderTicketRef(dcOrVars, vars));
};

const cambiarEstadoTicketRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CambiarEstadoTicket', inputVars);
}
cambiarEstadoTicketRef.operationName = 'CambiarEstadoTicket';
exports.cambiarEstadoTicketRef = cambiarEstadoTicketRef;

exports.cambiarEstadoTicket = function cambiarEstadoTicket(dcOrVars, vars) {
  return executeMutation(cambiarEstadoTicketRef(dcOrVars, vars));
};

const emitirCertificacionRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'EmitirCertificacion', inputVars);
}
emitirCertificacionRef.operationName = 'EmitirCertificacion';
exports.emitirCertificacionRef = emitirCertificacionRef;

exports.emitirCertificacion = function emitirCertificacion(dcOrVars, vars) {
  return executeMutation(emitirCertificacionRef(dcOrVars, vars));
};

const getMiPerfilRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetMiPerfil');
}
getMiPerfilRef.operationName = 'GetMiPerfil';
exports.getMiPerfilRef = getMiPerfilRef;

exports.getMiPerfil = function getMiPerfil(dc) {
  return executeQuery(getMiPerfilRef(dc));
};

const getAllCoachesRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetAllCoaches');
}
getAllCoachesRef.operationName = 'GetAllCoaches';
exports.getAllCoachesRef = getAllCoachesRef;

exports.getAllCoaches = function getAllCoaches(dc) {
  return executeQuery(getAllCoachesRef(dc));
};

const getAllNutriologosRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetAllNutriologos');
}
getAllNutriologosRef.operationName = 'GetAllNutriologos';
exports.getAllNutriologosRef = getAllNutriologosRef;

exports.getAllNutriologos = function getAllNutriologos(dc) {
  return executeQuery(getAllNutriologosRef(dc));
};

const getClientesByCoachRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetClientesByCoach', inputVars);
}
getClientesByCoachRef.operationName = 'GetClientesByCoach';
exports.getClientesByCoachRef = getClientesByCoachRef;

exports.getClientesByCoach = function getClientesByCoach(dcOrVars, vars) {
  return executeQuery(getClientesByCoachRef(dcOrVars, vars));
};

const getClientesByNutriologoRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetClientesByNutriologo', inputVars);
}
getClientesByNutriologoRef.operationName = 'GetClientesByNutriologo';
exports.getClientesByNutriologoRef = getClientesByNutriologoRef;

exports.getClientesByNutriologo = function getClientesByNutriologo(dcOrVars, vars) {
  return executeQuery(getClientesByNutriologoRef(dcOrVars, vars));
};

const getProgresoClienteRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetProgresoCliente', inputVars);
}
getProgresoClienteRef.operationName = 'GetProgresoCliente';
exports.getProgresoClienteRef = getProgresoClienteRef;

exports.getProgresoCliente = function getProgresoCliente(dcOrVars, vars) {
  return executeQuery(getProgresoClienteRef(dcOrVars, vars));
};

const getPlanNutricionalRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetPlanNutricional', inputVars);
}
getPlanNutricionalRef.operationName = 'GetPlanNutricional';
exports.getPlanNutricionalRef = getPlanNutricionalRef;

exports.getPlanNutricional = function getPlanNutricional(dcOrVars, vars) {
  return executeQuery(getPlanNutricionalRef(dcOrVars, vars));
};

const getAllTicketsRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetAllTickets');
}
getAllTicketsRef.operationName = 'GetAllTickets';
exports.getAllTicketsRef = getAllTicketsRef;

exports.getAllTickets = function getAllTickets(dc) {
  return executeQuery(getAllTicketsRef(dc));
};

const getMensajesTicketRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetMensajesTicket', inputVars);
}
getMensajesTicketRef.operationName = 'GetMensajesTicket';
exports.getMensajesTicketRef = getMensajesTicketRef;

exports.getMensajesTicket = function getMensajesTicket(dcOrVars, vars) {
  return executeQuery(getMensajesTicketRef(dcOrVars, vars));
};

const getCertificacionesRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetCertificaciones', inputVars);
}
getCertificacionesRef.operationName = 'GetCertificaciones';
exports.getCertificacionesRef = getCertificacionesRef;

exports.getCertificaciones = function getCertificaciones(dcOrVars, vars) {
  return executeQuery(getCertificacionesRef(dcOrVars, vars));
};

const getMisClientesRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetMisClientes');
}
getMisClientesRef.operationName = 'GetMisClientes';
exports.getMisClientesRef = getMisClientesRef;

exports.getMisClientes = function getMisClientes(dc) {
  return executeQuery(getMisClientesRef(dc));
};

const getRutinasByClienteRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetRutinasByCliente', inputVars);
}
getRutinasByClienteRef.operationName = 'GetRutinasByCliente';
exports.getRutinasByClienteRef = getRutinasByClienteRef;

exports.getRutinasByCliente = function getRutinasByCliente(dcOrVars, vars) {
  return executeQuery(getRutinasByClienteRef(dcOrVars, vars));
};

const getEjerciciosRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetEjercicios');
}
getEjerciciosRef.operationName = 'GetEjercicios';
exports.getEjerciciosRef = getEjerciciosRef;

exports.getEjercicios = function getEjercicios(dc) {
  return executeQuery(getEjerciciosRef(dc));
};
