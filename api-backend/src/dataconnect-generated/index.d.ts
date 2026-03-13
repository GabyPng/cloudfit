import { ConnectorConfig, DataConnect, QueryRef, QueryPromise, MutationRef, MutationPromise } from 'firebase/data-connect';

export const connectorConfig: ConnectorConfig;

export type TimestampString = string;
export type UUIDString = string;
export type Int64String = string;
export type DateString = string;


export enum EstadoTicket {
  ABIERTO = "ABIERTO",
  EN_PROGRESO = "EN_PROGRESO",
  CERRADO = "CERRADO",
};

export enum Role {
  ADMINISTRADOR = "ADMINISTRADOR",
  COACH = "COACH",
  NUTRIOLOGO = "NUTRIOLOGO",
  CLIENTE = "CLIENTE",
};



export interface Administrador_Key {
  id: UUIDString;
  __typename?: 'Administrador_Key';
}

export interface AgregarEjercicioARutinaData {
  rutinaEjercicio_insert: RutinaEjercicio_Key;
}

export interface AgregarEjercicioARutinaVariables {
  rutinaId: UUIDString;
  ejercicioId: UUIDString;
  series?: number | null;
  repeticiones?: number | null;
  descansoSegundos?: number | null;
  orden?: number | null;
}

export interface CambiarEstadoTicketData {
  ticket_update?: Ticket_Key | null;
}

export interface CambiarEstadoTicketVariables {
  id: UUIDString;
  estado: EstadoTicket;
}

export interface Certificacion_Key {
  id: UUIDString;
  __typename?: 'Certificacion_Key';
}

export interface Cliente_Key {
  id: UUIDString;
  __typename?: 'Cliente_Key';
}

export interface Coach_Key {
  id: UUIDString;
  __typename?: 'Coach_Key';
}

export interface CrearClienteData {
  cliente_insert: Cliente_Key;
}

export interface CrearClienteVariables {
  coachId?: UUIDString | null;
  nutriologoId?: UUIDString | null;
  fechaNacimiento?: DateString | null;
  altura?: number | null;
}

export interface CrearCoachData {
  coach_insert: Coach_Key;
}

export interface CrearCoachVariables {
  especialidad: string;
  aniosExperiencia: number;
}

export interface CrearEjercicioData {
  ejercicio_insert: Ejercicio_Key;
}

export interface CrearEjercicioVariables {
  nombre: string;
  descripcion?: string | null;
  grupoMuscular?: string | null;
}

export interface CrearNutriologoData {
  nutriologo_insert: Nutriologo_Key;
}

export interface CrearNutriologoVariables {
  enfoque: string;
  cedulaProfesional: string;
}

export interface CrearPerfilData {
  perfilUsuario_insert: PerfilUsuario_Key;
}

export interface CrearPerfilVariables {
  foto?: string | null;
  descripcion?: string | null;
}

export interface CrearPlanNutricionalData {
  planNutricional_insert: PlanNutricional_Key;
}

export interface CrearPlanNutricionalVariables {
  clienteId: UUIDString;
  descripcion: string;
  fechaFin?: DateString | null;
}

export interface CrearRutinaData {
  rutina_insert: Rutina_Key;
}

export interface CrearRutinaVariables {
  clienteId: UUIDString;
  nombre: string;
  descripcion?: string | null;
  fechaFin?: DateString | null;
}

export interface CrearTicketData {
  ticket_insert: Ticket_Key;
}

export interface CrearTicketVariables {
  asunto: string;
}

export interface CreateUsuarioData {
  usuario_insert: Usuario_Key;
}

export interface CreateUsuarioVariables {
  nombre: string;
  correo: string;
  contrasena: string;
  rol: Role;
}

export interface Ejercicio_Key {
  id: UUIDString;
  __typename?: 'Ejercicio_Key';
}

export interface EmitirCertificacionData {
  certificacion_insert: Certificacion_Key;
}

export interface EmitirCertificacionVariables {
  usuarioId: string;
  titulo: string;
}

export interface Gestion_Key {
  id: UUIDString;
  __typename?: 'Gestion_Key';
}

export interface GetAllCoachesData {
  coaches: ({
    especialidad?: string | null;
    aniosExperiencia?: number | null;
    coach: {
      id: string;
      nombre: string;
    } & Usuario_Key;
  })[];
}

export interface GetAllNutriologosData {
  nutriologos: ({
    enfoque?: string | null;
    cedulaProfesional?: string | null;
    nutriologo: {
      id: string;
      nombre: string;
    } & Usuario_Key;
  })[];
}

export interface GetAllTicketsData {
  tickets: ({
    id: UUIDString;
    asunto?: string | null;
    estado: EstadoTicket;
    fechaCreacion?: DateString | null;
    usuario: {
      nombre: string;
      correo: string;
    };
  } & Ticket_Key)[];
}

export interface GetCertificacionesData {
  certificacions: ({
    titulo?: string | null;
    fechaAprobacion: DateString;
    administrador: {
      usuario: {
        nombre: string;
      };
    };
  })[];
}

export interface GetCertificacionesVariables {
  usuarioId: string;
}

export interface GetClientesByCoachData {
  clientes: ({
    fechaNacimiento?: DateString | null;
    altura?: number | null;
    usuario: {
      nombre: string;
      correo: string;
    };
  })[];
}

export interface GetClientesByCoachVariables {
  coachId: UUIDString;
}

export interface GetClientesByNutriologoData {
  clientes: ({
    fechaNacimiento?: DateString | null;
    altura?: number | null;
    usuario: {
      nombre: string;
      correo: string;
    };
  })[];
}

export interface GetClientesByNutriologoVariables {
  nutriologoId: UUIDString;
}

export interface GetEjerciciosData {
  ejercicios: ({
    id: UUIDString;
    nombre: string;
    descripcion?: string | null;
    grupoMuscular?: string | null;
  } & Ejercicio_Key)[];
}

export interface GetMensajesTicketData {
  mensajeTickets: ({
    contenido?: string | null;
    fechaEnvio?: DateString | null;
    remitente: {
      nombre: string;
    };
  })[];
}

export interface GetMensajesTicketVariables {
  ticketId: UUIDString;
}

export interface GetMiPerfilData {
  perfilUsuarios: ({
    foto?: string | null;
    descripcion?: string | null;
    usuario: {
      nombre: string;
      correo: string;
      rol: Role;
    };
  })[];
}

export interface GetMisClientesData {
  clientes: ({
    usuarioId: string;
    usuario: {
      nombre: string;
    };
      fechaNacimiento?: DateString | null;
      altura?: number | null;
  })[];
}

export interface GetPlanNutricionalData {
  planNutricionals: ({
    descripcion?: string | null;
    fechaInicio?: DateString | null;
    fechaFin?: DateString | null;
  })[];
}

export interface GetPlanNutricionalVariables {
  clienteId: UUIDString;
}

export interface GetProgresoClienteData {
  progresos: ({
    peso?: number | null;
    imc?: number | null;
    fecha?: DateString | null;
  })[];
}

export interface GetProgresoClienteVariables {
  clienteId: UUIDString;
}

export interface GetRutinasByClienteData {
  rutinas: ({
    id: UUIDString;
    nombre: string;
    descripcion?: string | null;
    fechaInicio?: DateString | null;
    fechaFin?: DateString | null;
    ejercicios: ({
      series?: number | null;
      repeticiones?: number | null;
      descansoSegundos?: number | null;
      orden?: number | null;
      ejercicio: {
        nombre: string;
        grupoMuscular?: string | null;
      };
    })[];
  } & Rutina_Key)[];
}

export interface GetRutinasByClienteVariables {
  clienteId: UUIDString;
}

export interface MensajeTicket_Key {
  id: UUIDString;
  __typename?: 'MensajeTicket_Key';
}

export interface Nutriologo_Key {
  id: UUIDString;
  __typename?: 'Nutriologo_Key';
}

export interface PerfilUsuario_Key {
  id: UUIDString;
  __typename?: 'PerfilUsuario_Key';
}

export interface PlanNutricional_Key {
  id: UUIDString;
  __typename?: 'PlanNutricional_Key';
}

export interface Progreso_Key {
  id: UUIDString;
  __typename?: 'Progreso_Key';
}

export interface RegistrarProgresoData {
  progreso_insert: Progreso_Key;
}

export interface RegistrarProgresoVariables {
  clienteId: UUIDString;
  peso: number;
  imc: number;
}

export interface ResponderTicketData {
  mensajeTicket_insert: MensajeTicket_Key;
}

export interface ResponderTicketVariables {
  ticketId: UUIDString;
  contenido: string;
}

export interface RutinaEjercicio_Key {
  id: UUIDString;
  __typename?: 'RutinaEjercicio_Key';
}

export interface Rutina_Key {
  id: UUIDString;
  __typename?: 'Rutina_Key';
}

export interface Ticket_Key {
  id: UUIDString;
  __typename?: 'Ticket_Key';
}

export interface Usuario_Key {
  id: string;
  __typename?: 'Usuario_Key';
}

interface GetMiPerfilRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetMiPerfilData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<GetMiPerfilData, undefined>;
  operationName: string;
}
export const getMiPerfilRef: GetMiPerfilRef;

export function getMiPerfil(): QueryPromise<GetMiPerfilData, undefined>;
export function getMiPerfil(dc: DataConnect): QueryPromise<GetMiPerfilData, undefined>;

interface GetAllCoachesRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetAllCoachesData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<GetAllCoachesData, undefined>;
  operationName: string;
}
export const getAllCoachesRef: GetAllCoachesRef;

export function getAllCoaches(): QueryPromise<GetAllCoachesData, undefined>;
export function getAllCoaches(dc: DataConnect): QueryPromise<GetAllCoachesData, undefined>;

interface GetAllNutriologosRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetAllNutriologosData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<GetAllNutriologosData, undefined>;
  operationName: string;
}
export const getAllNutriologosRef: GetAllNutriologosRef;

export function getAllNutriologos(): QueryPromise<GetAllNutriologosData, undefined>;
export function getAllNutriologos(dc: DataConnect): QueryPromise<GetAllNutriologosData, undefined>;

interface GetClientesByCoachRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetClientesByCoachVariables): QueryRef<GetClientesByCoachData, GetClientesByCoachVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetClientesByCoachVariables): QueryRef<GetClientesByCoachData, GetClientesByCoachVariables>;
  operationName: string;
}
export const getClientesByCoachRef: GetClientesByCoachRef;

export function getClientesByCoach(vars: GetClientesByCoachVariables): QueryPromise<GetClientesByCoachData, GetClientesByCoachVariables>;
export function getClientesByCoach(dc: DataConnect, vars: GetClientesByCoachVariables): QueryPromise<GetClientesByCoachData, GetClientesByCoachVariables>;

interface GetClientesByNutriologoRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetClientesByNutriologoVariables): QueryRef<GetClientesByNutriologoData, GetClientesByNutriologoVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetClientesByNutriologoVariables): QueryRef<GetClientesByNutriologoData, GetClientesByNutriologoVariables>;
  operationName: string;
}
export const getClientesByNutriologoRef: GetClientesByNutriologoRef;

export function getClientesByNutriologo(vars: GetClientesByNutriologoVariables): QueryPromise<GetClientesByNutriologoData, GetClientesByNutriologoVariables>;
export function getClientesByNutriologo(dc: DataConnect, vars: GetClientesByNutriologoVariables): QueryPromise<GetClientesByNutriologoData, GetClientesByNutriologoVariables>;

interface GetProgresoClienteRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetProgresoClienteVariables): QueryRef<GetProgresoClienteData, GetProgresoClienteVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetProgresoClienteVariables): QueryRef<GetProgresoClienteData, GetProgresoClienteVariables>;
  operationName: string;
}
export const getProgresoClienteRef: GetProgresoClienteRef;

export function getProgresoCliente(vars: GetProgresoClienteVariables): QueryPromise<GetProgresoClienteData, GetProgresoClienteVariables>;
export function getProgresoCliente(dc: DataConnect, vars: GetProgresoClienteVariables): QueryPromise<GetProgresoClienteData, GetProgresoClienteVariables>;

interface GetPlanNutricionalRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetPlanNutricionalVariables): QueryRef<GetPlanNutricionalData, GetPlanNutricionalVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetPlanNutricionalVariables): QueryRef<GetPlanNutricionalData, GetPlanNutricionalVariables>;
  operationName: string;
}
export const getPlanNutricionalRef: GetPlanNutricionalRef;

export function getPlanNutricional(vars: GetPlanNutricionalVariables): QueryPromise<GetPlanNutricionalData, GetPlanNutricionalVariables>;
export function getPlanNutricional(dc: DataConnect, vars: GetPlanNutricionalVariables): QueryPromise<GetPlanNutricionalData, GetPlanNutricionalVariables>;

interface GetAllTicketsRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetAllTicketsData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<GetAllTicketsData, undefined>;
  operationName: string;
}
export const getAllTicketsRef: GetAllTicketsRef;

export function getAllTickets(): QueryPromise<GetAllTicketsData, undefined>;
export function getAllTickets(dc: DataConnect): QueryPromise<GetAllTicketsData, undefined>;

interface GetMensajesTicketRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetMensajesTicketVariables): QueryRef<GetMensajesTicketData, GetMensajesTicketVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetMensajesTicketVariables): QueryRef<GetMensajesTicketData, GetMensajesTicketVariables>;
  operationName: string;
}
export const getMensajesTicketRef: GetMensajesTicketRef;

export function getMensajesTicket(vars: GetMensajesTicketVariables): QueryPromise<GetMensajesTicketData, GetMensajesTicketVariables>;
export function getMensajesTicket(dc: DataConnect, vars: GetMensajesTicketVariables): QueryPromise<GetMensajesTicketData, GetMensajesTicketVariables>;

interface GetCertificacionesRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetCertificacionesVariables): QueryRef<GetCertificacionesData, GetCertificacionesVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetCertificacionesVariables): QueryRef<GetCertificacionesData, GetCertificacionesVariables>;
  operationName: string;
}
export const getCertificacionesRef: GetCertificacionesRef;

export function getCertificaciones(vars: GetCertificacionesVariables): QueryPromise<GetCertificacionesData, GetCertificacionesVariables>;
export function getCertificaciones(dc: DataConnect, vars: GetCertificacionesVariables): QueryPromise<GetCertificacionesData, GetCertificacionesVariables>;

interface GetMisClientesRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetMisClientesData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<GetMisClientesData, undefined>;
  operationName: string;
}
export const getMisClientesRef: GetMisClientesRef;

export function getMisClientes(): QueryPromise<GetMisClientesData, undefined>;
export function getMisClientes(dc: DataConnect): QueryPromise<GetMisClientesData, undefined>;

interface GetRutinasByClienteRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetRutinasByClienteVariables): QueryRef<GetRutinasByClienteData, GetRutinasByClienteVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetRutinasByClienteVariables): QueryRef<GetRutinasByClienteData, GetRutinasByClienteVariables>;
  operationName: string;
}
export const getRutinasByClienteRef: GetRutinasByClienteRef;

export function getRutinasByCliente(vars: GetRutinasByClienteVariables): QueryPromise<GetRutinasByClienteData, GetRutinasByClienteVariables>;
export function getRutinasByCliente(dc: DataConnect, vars: GetRutinasByClienteVariables): QueryPromise<GetRutinasByClienteData, GetRutinasByClienteVariables>;

interface GetEjerciciosRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetEjerciciosData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<GetEjerciciosData, undefined>;
  operationName: string;
}
export const getEjerciciosRef: GetEjerciciosRef;

export function getEjercicios(): QueryPromise<GetEjerciciosData, undefined>;
export function getEjercicios(dc: DataConnect): QueryPromise<GetEjerciciosData, undefined>;

interface CreateUsuarioRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateUsuarioVariables): MutationRef<CreateUsuarioData, CreateUsuarioVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateUsuarioVariables): MutationRef<CreateUsuarioData, CreateUsuarioVariables>;
  operationName: string;
}
export const createUsuarioRef: CreateUsuarioRef;

export function createUsuario(vars: CreateUsuarioVariables): MutationPromise<CreateUsuarioData, CreateUsuarioVariables>;
export function createUsuario(dc: DataConnect, vars: CreateUsuarioVariables): MutationPromise<CreateUsuarioData, CreateUsuarioVariables>;

interface CrearPerfilRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars?: CrearPerfilVariables): MutationRef<CrearPerfilData, CrearPerfilVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars?: CrearPerfilVariables): MutationRef<CrearPerfilData, CrearPerfilVariables>;
  operationName: string;
}
export const crearPerfilRef: CrearPerfilRef;

export function crearPerfil(vars?: CrearPerfilVariables): MutationPromise<CrearPerfilData, CrearPerfilVariables>;
export function crearPerfil(dc: DataConnect, vars?: CrearPerfilVariables): MutationPromise<CrearPerfilData, CrearPerfilVariables>;

interface CrearCoachRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearCoachVariables): MutationRef<CrearCoachData, CrearCoachVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CrearCoachVariables): MutationRef<CrearCoachData, CrearCoachVariables>;
  operationName: string;
}
export const crearCoachRef: CrearCoachRef;

export function crearCoach(vars: CrearCoachVariables): MutationPromise<CrearCoachData, CrearCoachVariables>;
export function crearCoach(dc: DataConnect, vars: CrearCoachVariables): MutationPromise<CrearCoachData, CrearCoachVariables>;

interface CrearNutriologoRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearNutriologoVariables): MutationRef<CrearNutriologoData, CrearNutriologoVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CrearNutriologoVariables): MutationRef<CrearNutriologoData, CrearNutriologoVariables>;
  operationName: string;
}
export const crearNutriologoRef: CrearNutriologoRef;

export function crearNutriologo(vars: CrearNutriologoVariables): MutationPromise<CrearNutriologoData, CrearNutriologoVariables>;
export function crearNutriologo(dc: DataConnect, vars: CrearNutriologoVariables): MutationPromise<CrearNutriologoData, CrearNutriologoVariables>;

interface CrearClienteRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars?: CrearClienteVariables): MutationRef<CrearClienteData, CrearClienteVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars?: CrearClienteVariables): MutationRef<CrearClienteData, CrearClienteVariables>;
  operationName: string;
}
export const crearClienteRef: CrearClienteRef;

export function crearCliente(vars?: CrearClienteVariables): MutationPromise<CrearClienteData, CrearClienteVariables>;
export function crearCliente(dc: DataConnect, vars?: CrearClienteVariables): MutationPromise<CrearClienteData, CrearClienteVariables>;

interface RegistrarProgresoRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: RegistrarProgresoVariables): MutationRef<RegistrarProgresoData, RegistrarProgresoVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: RegistrarProgresoVariables): MutationRef<RegistrarProgresoData, RegistrarProgresoVariables>;
  operationName: string;
}
export const registrarProgresoRef: RegistrarProgresoRef;

export function registrarProgreso(vars: RegistrarProgresoVariables): MutationPromise<RegistrarProgresoData, RegistrarProgresoVariables>;
export function registrarProgreso(dc: DataConnect, vars: RegistrarProgresoVariables): MutationPromise<RegistrarProgresoData, RegistrarProgresoVariables>;

interface CrearEjercicioRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearEjercicioVariables): MutationRef<CrearEjercicioData, CrearEjercicioVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CrearEjercicioVariables): MutationRef<CrearEjercicioData, CrearEjercicioVariables>;
  operationName: string;
}
export const crearEjercicioRef: CrearEjercicioRef;

export function crearEjercicio(vars: CrearEjercicioVariables): MutationPromise<CrearEjercicioData, CrearEjercicioVariables>;
export function crearEjercicio(dc: DataConnect, vars: CrearEjercicioVariables): MutationPromise<CrearEjercicioData, CrearEjercicioVariables>;

interface CrearRutinaRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearRutinaVariables): MutationRef<CrearRutinaData, CrearRutinaVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CrearRutinaVariables): MutationRef<CrearRutinaData, CrearRutinaVariables>;
  operationName: string;
}
export const crearRutinaRef: CrearRutinaRef;

export function crearRutina(vars: CrearRutinaVariables): MutationPromise<CrearRutinaData, CrearRutinaVariables>;
export function crearRutina(dc: DataConnect, vars: CrearRutinaVariables): MutationPromise<CrearRutinaData, CrearRutinaVariables>;

interface AgregarEjercicioARutinaRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: AgregarEjercicioARutinaVariables): MutationRef<AgregarEjercicioARutinaData, AgregarEjercicioARutinaVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: AgregarEjercicioARutinaVariables): MutationRef<AgregarEjercicioARutinaData, AgregarEjercicioARutinaVariables>;
  operationName: string;
}
export const agregarEjercicioARutinaRef: AgregarEjercicioARutinaRef;

export function agregarEjercicioARutina(vars: AgregarEjercicioARutinaVariables): MutationPromise<AgregarEjercicioARutinaData, AgregarEjercicioARutinaVariables>;
export function agregarEjercicioARutina(dc: DataConnect, vars: AgregarEjercicioARutinaVariables): MutationPromise<AgregarEjercicioARutinaData, AgregarEjercicioARutinaVariables>;

interface CrearPlanNutricionalRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearPlanNutricionalVariables): MutationRef<CrearPlanNutricionalData, CrearPlanNutricionalVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CrearPlanNutricionalVariables): MutationRef<CrearPlanNutricionalData, CrearPlanNutricionalVariables>;
  operationName: string;
}
export const crearPlanNutricionalRef: CrearPlanNutricionalRef;

export function crearPlanNutricional(vars: CrearPlanNutricionalVariables): MutationPromise<CrearPlanNutricionalData, CrearPlanNutricionalVariables>;
export function crearPlanNutricional(dc: DataConnect, vars: CrearPlanNutricionalVariables): MutationPromise<CrearPlanNutricionalData, CrearPlanNutricionalVariables>;

interface CrearTicketRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearTicketVariables): MutationRef<CrearTicketData, CrearTicketVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CrearTicketVariables): MutationRef<CrearTicketData, CrearTicketVariables>;
  operationName: string;
}
export const crearTicketRef: CrearTicketRef;

export function crearTicket(vars: CrearTicketVariables): MutationPromise<CrearTicketData, CrearTicketVariables>;
export function crearTicket(dc: DataConnect, vars: CrearTicketVariables): MutationPromise<CrearTicketData, CrearTicketVariables>;

interface ResponderTicketRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: ResponderTicketVariables): MutationRef<ResponderTicketData, ResponderTicketVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: ResponderTicketVariables): MutationRef<ResponderTicketData, ResponderTicketVariables>;
  operationName: string;
}
export const responderTicketRef: ResponderTicketRef;

export function responderTicket(vars: ResponderTicketVariables): MutationPromise<ResponderTicketData, ResponderTicketVariables>;
export function responderTicket(dc: DataConnect, vars: ResponderTicketVariables): MutationPromise<ResponderTicketData, ResponderTicketVariables>;

interface CambiarEstadoTicketRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CambiarEstadoTicketVariables): MutationRef<CambiarEstadoTicketData, CambiarEstadoTicketVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CambiarEstadoTicketVariables): MutationRef<CambiarEstadoTicketData, CambiarEstadoTicketVariables>;
  operationName: string;
}
export const cambiarEstadoTicketRef: CambiarEstadoTicketRef;

export function cambiarEstadoTicket(vars: CambiarEstadoTicketVariables): MutationPromise<CambiarEstadoTicketData, CambiarEstadoTicketVariables>;
export function cambiarEstadoTicket(dc: DataConnect, vars: CambiarEstadoTicketVariables): MutationPromise<CambiarEstadoTicketData, CambiarEstadoTicketVariables>;

interface EmitirCertificacionRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: EmitirCertificacionVariables): MutationRef<EmitirCertificacionData, EmitirCertificacionVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: EmitirCertificacionVariables): MutationRef<EmitirCertificacionData, EmitirCertificacionVariables>;
  operationName: string;
}
export const emitirCertificacionRef: EmitirCertificacionRef;

export function emitirCertificacion(vars: EmitirCertificacionVariables): MutationPromise<EmitirCertificacionData, EmitirCertificacionVariables>;
export function emitirCertificacion(dc: DataConnect, vars: EmitirCertificacionVariables): MutationPromise<EmitirCertificacionData, EmitirCertificacionVariables>;

