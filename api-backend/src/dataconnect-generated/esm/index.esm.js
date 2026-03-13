import { queryRef, executeQuery, mutationRef, executeMutation, validateArgs } from 'firebase/data-connect';

export const EstadoTicket = {
  ABIERTO: "ABIERTO",
  EN_PROGRESO: "EN_PROGRESO",
  CERRADO: "CERRADO",
}

export const Role = {
  ADMINISTRADOR: "ADMINISTRADOR",
  COACH: "COACH",
  NUTRIOLOGO: "NUTRIOLOGO",
  CLIENTE: "CLIENTE",
}

export const connectorConfig = {
  connector: 'example',
  service: 'cloudfit',
  location: 'us-east4'
};

export const getMiPerfilRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetMiPerfil');
}
getMiPerfilRef.operationName = 'GetMiPerfil';

export function getMiPerfil(dc) {
  return executeQuery(getMiPerfilRef(dc));
}

export const getAllCoachesRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetAllCoaches');
}
getAllCoachesRef.operationName = 'GetAllCoaches';

export function getAllCoaches(dc) {
  return executeQuery(getAllCoachesRef(dc));
}

export const getAllNutriologosRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetAllNutriologos');
}
getAllNutriologosRef.operationName = 'GetAllNutriologos';

export function getAllNutriologos(dc) {
  return executeQuery(getAllNutriologosRef(dc));
}

export const getClientesByCoachRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetClientesByCoach', inputVars);
}
getClientesByCoachRef.operationName = 'GetClientesByCoach';

export function getClientesByCoach(dcOrVars, vars) {
  return executeQuery(getClientesByCoachRef(dcOrVars, vars));
}

export const getClientesByNutriologoRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetClientesByNutriologo', inputVars);
}
getClientesByNutriologoRef.operationName = 'GetClientesByNutriologo';

export function getClientesByNutriologo(dcOrVars, vars) {
  return executeQuery(getClientesByNutriologoRef(dcOrVars, vars));
}

export const getProgresoClienteRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetProgresoCliente', inputVars);
}
getProgresoClienteRef.operationName = 'GetProgresoCliente';

export function getProgresoCliente(dcOrVars, vars) {
  return executeQuery(getProgresoClienteRef(dcOrVars, vars));
}

export const getPlanNutricionalRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetPlanNutricional', inputVars);
}
getPlanNutricionalRef.operationName = 'GetPlanNutricional';

export function getPlanNutricional(dcOrVars, vars) {
  return executeQuery(getPlanNutricionalRef(dcOrVars, vars));
}

export const getAllTicketsRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetAllTickets');
}
getAllTicketsRef.operationName = 'GetAllTickets';

export function getAllTickets(dc) {
  return executeQuery(getAllTicketsRef(dc));
}

export const getMensajesTicketRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetMensajesTicket', inputVars);
}
getMensajesTicketRef.operationName = 'GetMensajesTicket';

export function getMensajesTicket(dcOrVars, vars) {
  return executeQuery(getMensajesTicketRef(dcOrVars, vars));
}

export const getCertificacionesRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetCertificaciones', inputVars);
}
getCertificacionesRef.operationName = 'GetCertificaciones';

export function getCertificaciones(dcOrVars, vars) {
  return executeQuery(getCertificacionesRef(dcOrVars, vars));
}

export const getMisClientesRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetMisClientes');
}
getMisClientesRef.operationName = 'GetMisClientes';

export function getMisClientes(dc) {
  return executeQuery(getMisClientesRef(dc));
}

export const getRutinasByClienteRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetRutinasByCliente', inputVars);
}
getRutinasByClienteRef.operationName = 'GetRutinasByCliente';

export function getRutinasByCliente(dcOrVars, vars) {
  return executeQuery(getRutinasByClienteRef(dcOrVars, vars));
}

export const getEjerciciosRef = (dc) => {
  const { dc: dcInstance} = validateArgs(connectorConfig, dc, undefined);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetEjercicios');
}
getEjerciciosRef.operationName = 'GetEjercicios';

export function getEjercicios(dc) {
  return executeQuery(getEjerciciosRef(dc));
}

export const createUsuarioRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CreateUsuario', inputVars);
}
createUsuarioRef.operationName = 'CreateUsuario';

export function createUsuario(dcOrVars, vars) {
  return executeMutation(createUsuarioRef(dcOrVars, vars));
}

export const crearPerfilRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearPerfil', inputVars);
}
crearPerfilRef.operationName = 'CrearPerfil';

export function crearPerfil(dcOrVars, vars) {
  return executeMutation(crearPerfilRef(dcOrVars, vars));
}

export const crearCoachRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearCoach', inputVars);
}
crearCoachRef.operationName = 'CrearCoach';

export function crearCoach(dcOrVars, vars) {
  return executeMutation(crearCoachRef(dcOrVars, vars));
}

export const crearNutriologoRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearNutriologo', inputVars);
}
crearNutriologoRef.operationName = 'CrearNutriologo';

export function crearNutriologo(dcOrVars, vars) {
  return executeMutation(crearNutriologoRef(dcOrVars, vars));
}

export const crearClienteRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearCliente', inputVars);
}
crearClienteRef.operationName = 'CrearCliente';

export function crearCliente(dcOrVars, vars) {
  return executeMutation(crearClienteRef(dcOrVars, vars));
}

export const registrarProgresoRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'RegistrarProgreso', inputVars);
}
registrarProgresoRef.operationName = 'RegistrarProgreso';

export function registrarProgreso(dcOrVars, vars) {
  return executeMutation(registrarProgresoRef(dcOrVars, vars));
}

export const crearEjercicioRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearEjercicio', inputVars);
}
crearEjercicioRef.operationName = 'CrearEjercicio';

export function crearEjercicio(dcOrVars, vars) {
  return executeMutation(crearEjercicioRef(dcOrVars, vars));
}

export const crearRutinaRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearRutina', inputVars);
}
crearRutinaRef.operationName = 'CrearRutina';

export function crearRutina(dcOrVars, vars) {
  return executeMutation(crearRutinaRef(dcOrVars, vars));
}

export const agregarEjercicioARutinaRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'AgregarEjercicioARutina', inputVars);
}
agregarEjercicioARutinaRef.operationName = 'AgregarEjercicioARutina';

export function agregarEjercicioARutina(dcOrVars, vars) {
  return executeMutation(agregarEjercicioARutinaRef(dcOrVars, vars));
}

export const crearPlanNutricionalRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearPlanNutricional', inputVars);
}
crearPlanNutricionalRef.operationName = 'CrearPlanNutricional';

export function crearPlanNutricional(dcOrVars, vars) {
  return executeMutation(crearPlanNutricionalRef(dcOrVars, vars));
}

export const crearTicketRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CrearTicket', inputVars);
}
crearTicketRef.operationName = 'CrearTicket';

export function crearTicket(dcOrVars, vars) {
  return executeMutation(crearTicketRef(dcOrVars, vars));
}

export const responderTicketRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'ResponderTicket', inputVars);
}
responderTicketRef.operationName = 'ResponderTicket';

export function responderTicket(dcOrVars, vars) {
  return executeMutation(responderTicketRef(dcOrVars, vars));
}

export const cambiarEstadoTicketRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'CambiarEstadoTicket', inputVars);
}
cambiarEstadoTicketRef.operationName = 'CambiarEstadoTicket';

export function cambiarEstadoTicket(dcOrVars, vars) {
  return executeMutation(cambiarEstadoTicketRef(dcOrVars, vars));
}

export const emitirCertificacionRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'EmitirCertificacion', inputVars);
}
emitirCertificacionRef.operationName = 'EmitirCertificacion';

export function emitirCertificacion(dcOrVars, vars) {
  return executeMutation(emitirCertificacionRef(dcOrVars, vars));
}

