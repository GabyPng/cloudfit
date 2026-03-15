# Generated TypeScript README
This README will guide you through the process of using the generated JavaScript SDK package for the connector `example`. It will also provide examples on how to use your generated SDK to call your Data Connect queries and mutations.

***NOTE:** This README is generated alongside the generated SDK. If you make changes to this file, they will be overwritten when the SDK is regenerated.*

# Table of Contents
- [**Overview**](#generated-javascript-readme)
- [**Accessing the connector**](#accessing-the-connector)
  - [*Connecting to the local Emulator*](#connecting-to-the-local-emulator)
- [**Queries**](#queries)
  - [*GetMiPerfil*](#getmiperfil)
  - [*GetAllCoaches*](#getallcoaches)
  - [*GetAllNutriologos*](#getallnutriologos)
  - [*GetClientesByCoach*](#getclientesbycoach)
  - [*GetClientesByNutriologo*](#getclientesbynutriologo)
  - [*GetProgresoCliente*](#getprogresocliente)
  - [*GetPlanNutricional*](#getplannutricional)
  - [*GetAllTickets*](#getalltickets)
  - [*GetMensajesTicket*](#getmensajesticket)
  - [*GetCertificaciones*](#getcertificaciones)
  - [*GetMisClientes*](#getmisclientes)
  - [*GetRutinasByCliente*](#getrutinasbycliente)
  - [*GetEjercicios*](#getejercicios)
- [**Mutations**](#mutations)
  - [*CreateUsuario*](#createusuario)
  - [*CrearPerfil*](#crearperfil)
  - [*CrearCoach*](#crearcoach)
  - [*CrearNutriologo*](#crearnutriologo)
  - [*CrearCliente*](#crearcliente)
  - [*RegistrarProgreso*](#registrarprogreso)
  - [*CrearEjercicio*](#crearejercicio)
  - [*CrearRutina*](#crearrutina)
  - [*AgregarEjercicioARutina*](#agregarejercicioarutina)
  - [*CrearPlanNutricional*](#crearplannutricional)
  - [*CrearTicket*](#crearticket)
  - [*ResponderTicket*](#responderticket)
  - [*CambiarEstadoTicket*](#cambiarestadoticket)
  - [*EmitirCertificacion*](#emitircertificacion)

# Accessing the connector
A connector is a collection of Queries and Mutations. One SDK is generated for each connector - this SDK is generated for the connector `example`. You can find more information about connectors in the [Data Connect documentation](https://firebase.google.com/docs/data-connect#how-does).

You can use this generated SDK by importing from the package `@dataconnect/generated` as shown below. Both CommonJS and ESM imports are supported.

You can also follow the instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#set-client).

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@dataconnect/generated';

const dataConnect = getDataConnect(connectorConfig);
```

## Connecting to the local Emulator
By default, the connector will connect to the production service.

To connect to the emulator, you can use the following code.
You can also follow the emulator instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#instrument-clients).

```typescript
import { connectDataConnectEmulator, getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@dataconnect/generated';

const dataConnect = getDataConnect(connectorConfig);
connectDataConnectEmulator(dataConnect, 'localhost', 9399);
```

After it's initialized, you can call your Data Connect [queries](#queries) and [mutations](#mutations) from your generated SDK.

# Queries

There are two ways to execute a Data Connect Query using the generated Web SDK:
- Using a Query Reference function, which returns a `QueryRef`
  - The `QueryRef` can be used as an argument to `executeQuery()`, which will execute the Query and return a `QueryPromise`
- Using an action shortcut function, which returns a `QueryPromise`
  - Calling the action shortcut function will execute the Query and return a `QueryPromise`

The following is true for both the action shortcut function and the `QueryRef` function:
- The `QueryPromise` returned will resolve to the result of the Query once it has finished executing
- If the Query accepts arguments, both the action shortcut function and the `QueryRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Query
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `example` connector's generated functions to execute each query. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-queries).

## GetMiPerfil
You can execute the `GetMiPerfil` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getMiPerfil(): QueryPromise<GetMiPerfilData, undefined>;

interface GetMiPerfilRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetMiPerfilData, undefined>;
}
export const getMiPerfilRef: GetMiPerfilRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getMiPerfil(dc: DataConnect): QueryPromise<GetMiPerfilData, undefined>;

interface GetMiPerfilRef {
  ...
  (dc: DataConnect): QueryRef<GetMiPerfilData, undefined>;
}
export const getMiPerfilRef: GetMiPerfilRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getMiPerfilRef:
```typescript
const name = getMiPerfilRef.operationName;
console.log(name);
```

### Variables
The `GetMiPerfil` query has no variables.
### Return Type
Recall that executing the `GetMiPerfil` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetMiPerfilData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `GetMiPerfil`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getMiPerfil } from '@dataconnect/generated';


// Call the `getMiPerfil()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getMiPerfil();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getMiPerfil(dataConnect);

console.log(data.perfilUsuarios);

// Or, you can use the `Promise` API.
getMiPerfil().then((response) => {
  const data = response.data;
  console.log(data.perfilUsuarios);
});
```

### Using `GetMiPerfil`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getMiPerfilRef } from '@dataconnect/generated';


// Call the `getMiPerfilRef()` function to get a reference to the query.
const ref = getMiPerfilRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getMiPerfilRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.perfilUsuarios);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.perfilUsuarios);
});
```

## GetAllCoaches
You can execute the `GetAllCoaches` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getAllCoaches(): QueryPromise<GetAllCoachesData, undefined>;

interface GetAllCoachesRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetAllCoachesData, undefined>;
}
export const getAllCoachesRef: GetAllCoachesRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getAllCoaches(dc: DataConnect): QueryPromise<GetAllCoachesData, undefined>;

interface GetAllCoachesRef {
  ...
  (dc: DataConnect): QueryRef<GetAllCoachesData, undefined>;
}
export const getAllCoachesRef: GetAllCoachesRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getAllCoachesRef:
```typescript
const name = getAllCoachesRef.operationName;
console.log(name);
```

### Variables
The `GetAllCoaches` query has no variables.
### Return Type
Recall that executing the `GetAllCoaches` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetAllCoachesData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `GetAllCoaches`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getAllCoaches } from '@dataconnect/generated';


// Call the `getAllCoaches()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getAllCoaches();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getAllCoaches(dataConnect);

console.log(data.coaches);

// Or, you can use the `Promise` API.
getAllCoaches().then((response) => {
  const data = response.data;
  console.log(data.coaches);
});
```

### Using `GetAllCoaches`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getAllCoachesRef } from '@dataconnect/generated';


// Call the `getAllCoachesRef()` function to get a reference to the query.
const ref = getAllCoachesRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getAllCoachesRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.coaches);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.coaches);
});
```

## GetAllNutriologos
You can execute the `GetAllNutriologos` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getAllNutriologos(): QueryPromise<GetAllNutriologosData, undefined>;

interface GetAllNutriologosRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetAllNutriologosData, undefined>;
}
export const getAllNutriologosRef: GetAllNutriologosRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getAllNutriologos(dc: DataConnect): QueryPromise<GetAllNutriologosData, undefined>;

interface GetAllNutriologosRef {
  ...
  (dc: DataConnect): QueryRef<GetAllNutriologosData, undefined>;
}
export const getAllNutriologosRef: GetAllNutriologosRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getAllNutriologosRef:
```typescript
const name = getAllNutriologosRef.operationName;
console.log(name);
```

### Variables
The `GetAllNutriologos` query has no variables.
### Return Type
Recall that executing the `GetAllNutriologos` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetAllNutriologosData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `GetAllNutriologos`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getAllNutriologos } from '@dataconnect/generated';


// Call the `getAllNutriologos()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getAllNutriologos();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getAllNutriologos(dataConnect);

console.log(data.nutriologos);

// Or, you can use the `Promise` API.
getAllNutriologos().then((response) => {
  const data = response.data;
  console.log(data.nutriologos);
});
```

### Using `GetAllNutriologos`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getAllNutriologosRef } from '@dataconnect/generated';


// Call the `getAllNutriologosRef()` function to get a reference to the query.
const ref = getAllNutriologosRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getAllNutriologosRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.nutriologos);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.nutriologos);
});
```

## GetClientesByCoach
You can execute the `GetClientesByCoach` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getClientesByCoach(vars: GetClientesByCoachVariables): QueryPromise<GetClientesByCoachData, GetClientesByCoachVariables>;

interface GetClientesByCoachRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetClientesByCoachVariables): QueryRef<GetClientesByCoachData, GetClientesByCoachVariables>;
}
export const getClientesByCoachRef: GetClientesByCoachRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getClientesByCoach(dc: DataConnect, vars: GetClientesByCoachVariables): QueryPromise<GetClientesByCoachData, GetClientesByCoachVariables>;

interface GetClientesByCoachRef {
  ...
  (dc: DataConnect, vars: GetClientesByCoachVariables): QueryRef<GetClientesByCoachData, GetClientesByCoachVariables>;
}
export const getClientesByCoachRef: GetClientesByCoachRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getClientesByCoachRef:
```typescript
const name = getClientesByCoachRef.operationName;
console.log(name);
```

### Variables
The `GetClientesByCoach` query requires an argument of type `GetClientesByCoachVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetClientesByCoachVariables {
  coachId: UUIDString;
}
```
### Return Type
Recall that executing the `GetClientesByCoach` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetClientesByCoachData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `GetClientesByCoach`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getClientesByCoach, GetClientesByCoachVariables } from '@dataconnect/generated';

// The `GetClientesByCoach` query requires an argument of type `GetClientesByCoachVariables`:
const getClientesByCoachVars: GetClientesByCoachVariables = {
  coachId: ..., 
};

// Call the `getClientesByCoach()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getClientesByCoach(getClientesByCoachVars);
// Variables can be defined inline as well.
const { data } = await getClientesByCoach({ coachId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getClientesByCoach(dataConnect, getClientesByCoachVars);

console.log(data.clientes);

// Or, you can use the `Promise` API.
getClientesByCoach(getClientesByCoachVars).then((response) => {
  const data = response.data;
  console.log(data.clientes);
});
```

### Using `GetClientesByCoach`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getClientesByCoachRef, GetClientesByCoachVariables } from '@dataconnect/generated';

// The `GetClientesByCoach` query requires an argument of type `GetClientesByCoachVariables`:
const getClientesByCoachVars: GetClientesByCoachVariables = {
  coachId: ..., 
};

// Call the `getClientesByCoachRef()` function to get a reference to the query.
const ref = getClientesByCoachRef(getClientesByCoachVars);
// Variables can be defined inline as well.
const ref = getClientesByCoachRef({ coachId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getClientesByCoachRef(dataConnect, getClientesByCoachVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.clientes);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.clientes);
});
```

## GetClientesByNutriologo
You can execute the `GetClientesByNutriologo` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getClientesByNutriologo(vars: GetClientesByNutriologoVariables): QueryPromise<GetClientesByNutriologoData, GetClientesByNutriologoVariables>;

interface GetClientesByNutriologoRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetClientesByNutriologoVariables): QueryRef<GetClientesByNutriologoData, GetClientesByNutriologoVariables>;
}
export const getClientesByNutriologoRef: GetClientesByNutriologoRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getClientesByNutriologo(dc: DataConnect, vars: GetClientesByNutriologoVariables): QueryPromise<GetClientesByNutriologoData, GetClientesByNutriologoVariables>;

interface GetClientesByNutriologoRef {
  ...
  (dc: DataConnect, vars: GetClientesByNutriologoVariables): QueryRef<GetClientesByNutriologoData, GetClientesByNutriologoVariables>;
}
export const getClientesByNutriologoRef: GetClientesByNutriologoRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getClientesByNutriologoRef:
```typescript
const name = getClientesByNutriologoRef.operationName;
console.log(name);
```

### Variables
The `GetClientesByNutriologo` query requires an argument of type `GetClientesByNutriologoVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetClientesByNutriologoVariables {
  nutriologoId: UUIDString;
}
```
### Return Type
Recall that executing the `GetClientesByNutriologo` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetClientesByNutriologoData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `GetClientesByNutriologo`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getClientesByNutriologo, GetClientesByNutriologoVariables } from '@dataconnect/generated';

// The `GetClientesByNutriologo` query requires an argument of type `GetClientesByNutriologoVariables`:
const getClientesByNutriologoVars: GetClientesByNutriologoVariables = {
  nutriologoId: ..., 
};

// Call the `getClientesByNutriologo()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getClientesByNutriologo(getClientesByNutriologoVars);
// Variables can be defined inline as well.
const { data } = await getClientesByNutriologo({ nutriologoId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getClientesByNutriologo(dataConnect, getClientesByNutriologoVars);

console.log(data.clientes);

// Or, you can use the `Promise` API.
getClientesByNutriologo(getClientesByNutriologoVars).then((response) => {
  const data = response.data;
  console.log(data.clientes);
});
```

### Using `GetClientesByNutriologo`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getClientesByNutriologoRef, GetClientesByNutriologoVariables } from '@dataconnect/generated';

// The `GetClientesByNutriologo` query requires an argument of type `GetClientesByNutriologoVariables`:
const getClientesByNutriologoVars: GetClientesByNutriologoVariables = {
  nutriologoId: ..., 
};

// Call the `getClientesByNutriologoRef()` function to get a reference to the query.
const ref = getClientesByNutriologoRef(getClientesByNutriologoVars);
// Variables can be defined inline as well.
const ref = getClientesByNutriologoRef({ nutriologoId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getClientesByNutriologoRef(dataConnect, getClientesByNutriologoVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.clientes);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.clientes);
});
```

## GetProgresoCliente
You can execute the `GetProgresoCliente` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getProgresoCliente(vars: GetProgresoClienteVariables): QueryPromise<GetProgresoClienteData, GetProgresoClienteVariables>;

interface GetProgresoClienteRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetProgresoClienteVariables): QueryRef<GetProgresoClienteData, GetProgresoClienteVariables>;
}
export const getProgresoClienteRef: GetProgresoClienteRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getProgresoCliente(dc: DataConnect, vars: GetProgresoClienteVariables): QueryPromise<GetProgresoClienteData, GetProgresoClienteVariables>;

interface GetProgresoClienteRef {
  ...
  (dc: DataConnect, vars: GetProgresoClienteVariables): QueryRef<GetProgresoClienteData, GetProgresoClienteVariables>;
}
export const getProgresoClienteRef: GetProgresoClienteRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getProgresoClienteRef:
```typescript
const name = getProgresoClienteRef.operationName;
console.log(name);
```

### Variables
The `GetProgresoCliente` query requires an argument of type `GetProgresoClienteVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetProgresoClienteVariables {
  clienteId: UUIDString;
}
```
### Return Type
Recall that executing the `GetProgresoCliente` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetProgresoClienteData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetProgresoClienteData {
  progresos: ({
    peso?: number | null;
    imc?: number | null;
    fecha?: DateString | null;
  })[];
}
```
### Using `GetProgresoCliente`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getProgresoCliente, GetProgresoClienteVariables } from '@dataconnect/generated';

// The `GetProgresoCliente` query requires an argument of type `GetProgresoClienteVariables`:
const getProgresoClienteVars: GetProgresoClienteVariables = {
  clienteId: ..., 
};

// Call the `getProgresoCliente()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getProgresoCliente(getProgresoClienteVars);
// Variables can be defined inline as well.
const { data } = await getProgresoCliente({ clienteId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getProgresoCliente(dataConnect, getProgresoClienteVars);

console.log(data.progresos);

// Or, you can use the `Promise` API.
getProgresoCliente(getProgresoClienteVars).then((response) => {
  const data = response.data;
  console.log(data.progresos);
});
```

### Using `GetProgresoCliente`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getProgresoClienteRef, GetProgresoClienteVariables } from '@dataconnect/generated';

// The `GetProgresoCliente` query requires an argument of type `GetProgresoClienteVariables`:
const getProgresoClienteVars: GetProgresoClienteVariables = {
  clienteId: ..., 
};

// Call the `getProgresoClienteRef()` function to get a reference to the query.
const ref = getProgresoClienteRef(getProgresoClienteVars);
// Variables can be defined inline as well.
const ref = getProgresoClienteRef({ clienteId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getProgresoClienteRef(dataConnect, getProgresoClienteVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.progresos);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.progresos);
});
```

## GetPlanNutricional
You can execute the `GetPlanNutricional` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getPlanNutricional(vars: GetPlanNutricionalVariables): QueryPromise<GetPlanNutricionalData, GetPlanNutricionalVariables>;

interface GetPlanNutricionalRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetPlanNutricionalVariables): QueryRef<GetPlanNutricionalData, GetPlanNutricionalVariables>;
}
export const getPlanNutricionalRef: GetPlanNutricionalRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getPlanNutricional(dc: DataConnect, vars: GetPlanNutricionalVariables): QueryPromise<GetPlanNutricionalData, GetPlanNutricionalVariables>;

interface GetPlanNutricionalRef {
  ...
  (dc: DataConnect, vars: GetPlanNutricionalVariables): QueryRef<GetPlanNutricionalData, GetPlanNutricionalVariables>;
}
export const getPlanNutricionalRef: GetPlanNutricionalRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getPlanNutricionalRef:
```typescript
const name = getPlanNutricionalRef.operationName;
console.log(name);
```

### Variables
The `GetPlanNutricional` query requires an argument of type `GetPlanNutricionalVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetPlanNutricionalVariables {
  clienteId: UUIDString;
}
```
### Return Type
Recall that executing the `GetPlanNutricional` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetPlanNutricionalData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetPlanNutricionalData {
  planNutricionals: ({
    descripcion?: string | null;
    fechaInicio?: DateString | null;
    fechaFin?: DateString | null;
  })[];
}
```
### Using `GetPlanNutricional`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getPlanNutricional, GetPlanNutricionalVariables } from '@dataconnect/generated';

// The `GetPlanNutricional` query requires an argument of type `GetPlanNutricionalVariables`:
const getPlanNutricionalVars: GetPlanNutricionalVariables = {
  clienteId: ..., 
};

// Call the `getPlanNutricional()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getPlanNutricional(getPlanNutricionalVars);
// Variables can be defined inline as well.
const { data } = await getPlanNutricional({ clienteId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getPlanNutricional(dataConnect, getPlanNutricionalVars);

console.log(data.planNutricionals);

// Or, you can use the `Promise` API.
getPlanNutricional(getPlanNutricionalVars).then((response) => {
  const data = response.data;
  console.log(data.planNutricionals);
});
```

### Using `GetPlanNutricional`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getPlanNutricionalRef, GetPlanNutricionalVariables } from '@dataconnect/generated';

// The `GetPlanNutricional` query requires an argument of type `GetPlanNutricionalVariables`:
const getPlanNutricionalVars: GetPlanNutricionalVariables = {
  clienteId: ..., 
};

// Call the `getPlanNutricionalRef()` function to get a reference to the query.
const ref = getPlanNutricionalRef(getPlanNutricionalVars);
// Variables can be defined inline as well.
const ref = getPlanNutricionalRef({ clienteId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getPlanNutricionalRef(dataConnect, getPlanNutricionalVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.planNutricionals);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.planNutricionals);
});
```

## GetAllTickets
You can execute the `GetAllTickets` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getAllTickets(): QueryPromise<GetAllTicketsData, undefined>;

interface GetAllTicketsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetAllTicketsData, undefined>;
}
export const getAllTicketsRef: GetAllTicketsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getAllTickets(dc: DataConnect): QueryPromise<GetAllTicketsData, undefined>;

interface GetAllTicketsRef {
  ...
  (dc: DataConnect): QueryRef<GetAllTicketsData, undefined>;
}
export const getAllTicketsRef: GetAllTicketsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getAllTicketsRef:
```typescript
const name = getAllTicketsRef.operationName;
console.log(name);
```

### Variables
The `GetAllTickets` query has no variables.
### Return Type
Recall that executing the `GetAllTickets` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetAllTicketsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `GetAllTickets`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getAllTickets } from '@dataconnect/generated';


// Call the `getAllTickets()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getAllTickets();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getAllTickets(dataConnect);

console.log(data.tickets);

// Or, you can use the `Promise` API.
getAllTickets().then((response) => {
  const data = response.data;
  console.log(data.tickets);
});
```

### Using `GetAllTickets`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getAllTicketsRef } from '@dataconnect/generated';


// Call the `getAllTicketsRef()` function to get a reference to the query.
const ref = getAllTicketsRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getAllTicketsRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.tickets);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.tickets);
});
```

## GetMensajesTicket
You can execute the `GetMensajesTicket` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getMensajesTicket(vars: GetMensajesTicketVariables): QueryPromise<GetMensajesTicketData, GetMensajesTicketVariables>;

interface GetMensajesTicketRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetMensajesTicketVariables): QueryRef<GetMensajesTicketData, GetMensajesTicketVariables>;
}
export const getMensajesTicketRef: GetMensajesTicketRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getMensajesTicket(dc: DataConnect, vars: GetMensajesTicketVariables): QueryPromise<GetMensajesTicketData, GetMensajesTicketVariables>;

interface GetMensajesTicketRef {
  ...
  (dc: DataConnect, vars: GetMensajesTicketVariables): QueryRef<GetMensajesTicketData, GetMensajesTicketVariables>;
}
export const getMensajesTicketRef: GetMensajesTicketRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getMensajesTicketRef:
```typescript
const name = getMensajesTicketRef.operationName;
console.log(name);
```

### Variables
The `GetMensajesTicket` query requires an argument of type `GetMensajesTicketVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetMensajesTicketVariables {
  ticketId: UUIDString;
}
```
### Return Type
Recall that executing the `GetMensajesTicket` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetMensajesTicketData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetMensajesTicketData {
  mensajeTickets: ({
    contenido?: string | null;
    fechaEnvio?: DateString | null;
    remitente: {
      nombre: string;
    };
  })[];
}
```
### Using `GetMensajesTicket`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getMensajesTicket, GetMensajesTicketVariables } from '@dataconnect/generated';

// The `GetMensajesTicket` query requires an argument of type `GetMensajesTicketVariables`:
const getMensajesTicketVars: GetMensajesTicketVariables = {
  ticketId: ..., 
};

// Call the `getMensajesTicket()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getMensajesTicket(getMensajesTicketVars);
// Variables can be defined inline as well.
const { data } = await getMensajesTicket({ ticketId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getMensajesTicket(dataConnect, getMensajesTicketVars);

console.log(data.mensajeTickets);

// Or, you can use the `Promise` API.
getMensajesTicket(getMensajesTicketVars).then((response) => {
  const data = response.data;
  console.log(data.mensajeTickets);
});
```

### Using `GetMensajesTicket`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getMensajesTicketRef, GetMensajesTicketVariables } from '@dataconnect/generated';

// The `GetMensajesTicket` query requires an argument of type `GetMensajesTicketVariables`:
const getMensajesTicketVars: GetMensajesTicketVariables = {
  ticketId: ..., 
};

// Call the `getMensajesTicketRef()` function to get a reference to the query.
const ref = getMensajesTicketRef(getMensajesTicketVars);
// Variables can be defined inline as well.
const ref = getMensajesTicketRef({ ticketId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getMensajesTicketRef(dataConnect, getMensajesTicketVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.mensajeTickets);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.mensajeTickets);
});
```

## GetCertificaciones
You can execute the `GetCertificaciones` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getCertificaciones(vars: GetCertificacionesVariables): QueryPromise<GetCertificacionesData, GetCertificacionesVariables>;

interface GetCertificacionesRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetCertificacionesVariables): QueryRef<GetCertificacionesData, GetCertificacionesVariables>;
}
export const getCertificacionesRef: GetCertificacionesRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getCertificaciones(dc: DataConnect, vars: GetCertificacionesVariables): QueryPromise<GetCertificacionesData, GetCertificacionesVariables>;

interface GetCertificacionesRef {
  ...
  (dc: DataConnect, vars: GetCertificacionesVariables): QueryRef<GetCertificacionesData, GetCertificacionesVariables>;
}
export const getCertificacionesRef: GetCertificacionesRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getCertificacionesRef:
```typescript
const name = getCertificacionesRef.operationName;
console.log(name);
```

### Variables
The `GetCertificaciones` query requires an argument of type `GetCertificacionesVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetCertificacionesVariables {
  usuarioId: string;
}
```
### Return Type
Recall that executing the `GetCertificaciones` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetCertificacionesData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `GetCertificaciones`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getCertificaciones, GetCertificacionesVariables } from '@dataconnect/generated';

// The `GetCertificaciones` query requires an argument of type `GetCertificacionesVariables`:
const getCertificacionesVars: GetCertificacionesVariables = {
  usuarioId: ..., 
};

// Call the `getCertificaciones()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getCertificaciones(getCertificacionesVars);
// Variables can be defined inline as well.
const { data } = await getCertificaciones({ usuarioId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getCertificaciones(dataConnect, getCertificacionesVars);

console.log(data.certificacions);

// Or, you can use the `Promise` API.
getCertificaciones(getCertificacionesVars).then((response) => {
  const data = response.data;
  console.log(data.certificacions);
});
```

### Using `GetCertificaciones`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getCertificacionesRef, GetCertificacionesVariables } from '@dataconnect/generated';

// The `GetCertificaciones` query requires an argument of type `GetCertificacionesVariables`:
const getCertificacionesVars: GetCertificacionesVariables = {
  usuarioId: ..., 
};

// Call the `getCertificacionesRef()` function to get a reference to the query.
const ref = getCertificacionesRef(getCertificacionesVars);
// Variables can be defined inline as well.
const ref = getCertificacionesRef({ usuarioId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getCertificacionesRef(dataConnect, getCertificacionesVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.certificacions);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.certificacions);
});
```

## GetMisClientes
You can execute the `GetMisClientes` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getMisClientes(): QueryPromise<GetMisClientesData, undefined>;

interface GetMisClientesRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetMisClientesData, undefined>;
}
export const getMisClientesRef: GetMisClientesRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getMisClientes(dc: DataConnect): QueryPromise<GetMisClientesData, undefined>;

interface GetMisClientesRef {
  ...
  (dc: DataConnect): QueryRef<GetMisClientesData, undefined>;
}
export const getMisClientesRef: GetMisClientesRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getMisClientesRef:
```typescript
const name = getMisClientesRef.operationName;
console.log(name);
```

### Variables
The `GetMisClientes` query has no variables.
### Return Type
Recall that executing the `GetMisClientes` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetMisClientesData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `GetMisClientes`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getMisClientes } from '@dataconnect/generated';


// Call the `getMisClientes()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getMisClientes();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getMisClientes(dataConnect);

console.log(data.clientes);

// Or, you can use the `Promise` API.
getMisClientes().then((response) => {
  const data = response.data;
  console.log(data.clientes);
});
```

### Using `GetMisClientes`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getMisClientesRef } from '@dataconnect/generated';


// Call the `getMisClientesRef()` function to get a reference to the query.
const ref = getMisClientesRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getMisClientesRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.clientes);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.clientes);
});
```

## GetRutinasByCliente
You can execute the `GetRutinasByCliente` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getRutinasByCliente(vars: GetRutinasByClienteVariables): QueryPromise<GetRutinasByClienteData, GetRutinasByClienteVariables>;

interface GetRutinasByClienteRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetRutinasByClienteVariables): QueryRef<GetRutinasByClienteData, GetRutinasByClienteVariables>;
}
export const getRutinasByClienteRef: GetRutinasByClienteRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getRutinasByCliente(dc: DataConnect, vars: GetRutinasByClienteVariables): QueryPromise<GetRutinasByClienteData, GetRutinasByClienteVariables>;

interface GetRutinasByClienteRef {
  ...
  (dc: DataConnect, vars: GetRutinasByClienteVariables): QueryRef<GetRutinasByClienteData, GetRutinasByClienteVariables>;
}
export const getRutinasByClienteRef: GetRutinasByClienteRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getRutinasByClienteRef:
```typescript
const name = getRutinasByClienteRef.operationName;
console.log(name);
```

### Variables
The `GetRutinasByCliente` query requires an argument of type `GetRutinasByClienteVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetRutinasByClienteVariables {
  clienteId: UUIDString;
}
```
### Return Type
Recall that executing the `GetRutinasByCliente` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetRutinasByClienteData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `GetRutinasByCliente`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getRutinasByCliente, GetRutinasByClienteVariables } from '@dataconnect/generated';

// The `GetRutinasByCliente` query requires an argument of type `GetRutinasByClienteVariables`:
const getRutinasByClienteVars: GetRutinasByClienteVariables = {
  clienteId: ..., 
};

// Call the `getRutinasByCliente()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getRutinasByCliente(getRutinasByClienteVars);
// Variables can be defined inline as well.
const { data } = await getRutinasByCliente({ clienteId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getRutinasByCliente(dataConnect, getRutinasByClienteVars);

console.log(data.rutinas);

// Or, you can use the `Promise` API.
getRutinasByCliente(getRutinasByClienteVars).then((response) => {
  const data = response.data;
  console.log(data.rutinas);
});
```

### Using `GetRutinasByCliente`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getRutinasByClienteRef, GetRutinasByClienteVariables } from '@dataconnect/generated';

// The `GetRutinasByCliente` query requires an argument of type `GetRutinasByClienteVariables`:
const getRutinasByClienteVars: GetRutinasByClienteVariables = {
  clienteId: ..., 
};

// Call the `getRutinasByClienteRef()` function to get a reference to the query.
const ref = getRutinasByClienteRef(getRutinasByClienteVars);
// Variables can be defined inline as well.
const ref = getRutinasByClienteRef({ clienteId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getRutinasByClienteRef(dataConnect, getRutinasByClienteVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.rutinas);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.rutinas);
});
```

## GetEjercicios
You can execute the `GetEjercicios` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getEjercicios(): QueryPromise<GetEjerciciosData, undefined>;

interface GetEjerciciosRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetEjerciciosData, undefined>;
}
export const getEjerciciosRef: GetEjerciciosRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getEjercicios(dc: DataConnect): QueryPromise<GetEjerciciosData, undefined>;

interface GetEjerciciosRef {
  ...
  (dc: DataConnect): QueryRef<GetEjerciciosData, undefined>;
}
export const getEjerciciosRef: GetEjerciciosRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getEjerciciosRef:
```typescript
const name = getEjerciciosRef.operationName;
console.log(name);
```

### Variables
The `GetEjercicios` query has no variables.
### Return Type
Recall that executing the `GetEjercicios` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetEjerciciosData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetEjerciciosData {
  ejercicios: ({
    id: UUIDString;
    nombre: string;
    descripcion?: string | null;
    grupoMuscular?: string | null;
  } & Ejercicio_Key)[];
}
```
### Using `GetEjercicios`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getEjercicios } from '@dataconnect/generated';


// Call the `getEjercicios()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getEjercicios();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getEjercicios(dataConnect);

console.log(data.ejercicios);

// Or, you can use the `Promise` API.
getEjercicios().then((response) => {
  const data = response.data;
  console.log(data.ejercicios);
});
```

### Using `GetEjercicios`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getEjerciciosRef } from '@dataconnect/generated';


// Call the `getEjerciciosRef()` function to get a reference to the query.
const ref = getEjerciciosRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getEjerciciosRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.ejercicios);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.ejercicios);
});
```

# Mutations

There are two ways to execute a Data Connect Mutation using the generated Web SDK:
- Using a Mutation Reference function, which returns a `MutationRef`
  - The `MutationRef` can be used as an argument to `executeMutation()`, which will execute the Mutation and return a `MutationPromise`
- Using an action shortcut function, which returns a `MutationPromise`
  - Calling the action shortcut function will execute the Mutation and return a `MutationPromise`

The following is true for both the action shortcut function and the `MutationRef` function:
- The `MutationPromise` returned will resolve to the result of the Mutation once it has finished executing
- If the Mutation accepts arguments, both the action shortcut function and the `MutationRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Mutation
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `example` connector's generated functions to execute each mutation. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-mutations).

## CreateUsuario
You can execute the `CreateUsuario` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createUsuario(vars: CreateUsuarioVariables): MutationPromise<CreateUsuarioData, CreateUsuarioVariables>;

interface CreateUsuarioRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateUsuarioVariables): MutationRef<CreateUsuarioData, CreateUsuarioVariables>;
}
export const createUsuarioRef: CreateUsuarioRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createUsuario(dc: DataConnect, vars: CreateUsuarioVariables): MutationPromise<CreateUsuarioData, CreateUsuarioVariables>;

interface CreateUsuarioRef {
  ...
  (dc: DataConnect, vars: CreateUsuarioVariables): MutationRef<CreateUsuarioData, CreateUsuarioVariables>;
}
export const createUsuarioRef: CreateUsuarioRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createUsuarioRef:
```typescript
const name = createUsuarioRef.operationName;
console.log(name);
```

### Variables
The `CreateUsuario` mutation requires an argument of type `CreateUsuarioVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateUsuarioVariables {
  nombre: string;
  correo: string;
  contrasena: string;
  rol: Role;
}
```
### Return Type
Recall that executing the `CreateUsuario` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateUsuarioData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateUsuarioData {
  usuario_insert: Usuario_Key;
}
```
### Using `CreateUsuario`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createUsuario, CreateUsuarioVariables } from '@dataconnect/generated';

// The `CreateUsuario` mutation requires an argument of type `CreateUsuarioVariables`:
const createUsuarioVars: CreateUsuarioVariables = {
  nombre: ..., 
  correo: ..., 
  contrasena: ..., 
  rol: ..., 
};

// Call the `createUsuario()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createUsuario(createUsuarioVars);
// Variables can be defined inline as well.
const { data } = await createUsuario({ nombre: ..., correo: ..., contrasena: ..., rol: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createUsuario(dataConnect, createUsuarioVars);

console.log(data.usuario_insert);

// Or, you can use the `Promise` API.
createUsuario(createUsuarioVars).then((response) => {
  const data = response.data;
  console.log(data.usuario_insert);
});
```

### Using `CreateUsuario`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createUsuarioRef, CreateUsuarioVariables } from '@dataconnect/generated';

// The `CreateUsuario` mutation requires an argument of type `CreateUsuarioVariables`:
const createUsuarioVars: CreateUsuarioVariables = {
  nombre: ..., 
  correo: ..., 
  contrasena: ..., 
  rol: ..., 
};

// Call the `createUsuarioRef()` function to get a reference to the mutation.
const ref = createUsuarioRef(createUsuarioVars);
// Variables can be defined inline as well.
const ref = createUsuarioRef({ nombre: ..., correo: ..., contrasena: ..., rol: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createUsuarioRef(dataConnect, createUsuarioVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.usuario_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.usuario_insert);
});
```

## CrearPerfil
You can execute the `CrearPerfil` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
crearPerfil(vars?: CrearPerfilVariables): MutationPromise<CrearPerfilData, CrearPerfilVariables>;

interface CrearPerfilRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars?: CrearPerfilVariables): MutationRef<CrearPerfilData, CrearPerfilVariables>;
}
export const crearPerfilRef: CrearPerfilRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
crearPerfil(dc: DataConnect, vars?: CrearPerfilVariables): MutationPromise<CrearPerfilData, CrearPerfilVariables>;

interface CrearPerfilRef {
  ...
  (dc: DataConnect, vars?: CrearPerfilVariables): MutationRef<CrearPerfilData, CrearPerfilVariables>;
}
export const crearPerfilRef: CrearPerfilRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the crearPerfilRef:
```typescript
const name = crearPerfilRef.operationName;
console.log(name);
```

### Variables
The `CrearPerfil` mutation has an optional argument of type `CrearPerfilVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CrearPerfilVariables {
  foto?: string | null;
  descripcion?: string | null;
}
```
### Return Type
Recall that executing the `CrearPerfil` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CrearPerfilData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CrearPerfilData {
  perfilUsuario_insert: PerfilUsuario_Key;
}
```
### Using `CrearPerfil`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, crearPerfil, CrearPerfilVariables } from '@dataconnect/generated';

// The `CrearPerfil` mutation has an optional argument of type `CrearPerfilVariables`:
const crearPerfilVars: CrearPerfilVariables = {
  foto: ..., // optional
  descripcion: ..., // optional
};

// Call the `crearPerfil()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await crearPerfil(crearPerfilVars);
// Variables can be defined inline as well.
const { data } = await crearPerfil({ foto: ..., descripcion: ..., });
// Since all variables are optional for this mutation, you can omit the `CrearPerfilVariables` argument.
const { data } = await crearPerfil();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await crearPerfil(dataConnect, crearPerfilVars);

console.log(data.perfilUsuario_insert);

// Or, you can use the `Promise` API.
crearPerfil(crearPerfilVars).then((response) => {
  const data = response.data;
  console.log(data.perfilUsuario_insert);
});
```

### Using `CrearPerfil`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, crearPerfilRef, CrearPerfilVariables } from '@dataconnect/generated';

// The `CrearPerfil` mutation has an optional argument of type `CrearPerfilVariables`:
const crearPerfilVars: CrearPerfilVariables = {
  foto: ..., // optional
  descripcion: ..., // optional
};

// Call the `crearPerfilRef()` function to get a reference to the mutation.
const ref = crearPerfilRef(crearPerfilVars);
// Variables can be defined inline as well.
const ref = crearPerfilRef({ foto: ..., descripcion: ..., });
// Since all variables are optional for this mutation, you can omit the `CrearPerfilVariables` argument.
const ref = crearPerfilRef();

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = crearPerfilRef(dataConnect, crearPerfilVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.perfilUsuario_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.perfilUsuario_insert);
});
```

## CrearCoach
You can execute the `CrearCoach` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
crearCoach(vars: CrearCoachVariables): MutationPromise<CrearCoachData, CrearCoachVariables>;

interface CrearCoachRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearCoachVariables): MutationRef<CrearCoachData, CrearCoachVariables>;
}
export const crearCoachRef: CrearCoachRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
crearCoach(dc: DataConnect, vars: CrearCoachVariables): MutationPromise<CrearCoachData, CrearCoachVariables>;

interface CrearCoachRef {
  ...
  (dc: DataConnect, vars: CrearCoachVariables): MutationRef<CrearCoachData, CrearCoachVariables>;
}
export const crearCoachRef: CrearCoachRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the crearCoachRef:
```typescript
const name = crearCoachRef.operationName;
console.log(name);
```

### Variables
The `CrearCoach` mutation requires an argument of type `CrearCoachVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CrearCoachVariables {
  especialidad: string;
  aniosExperiencia: number;
}
```
### Return Type
Recall that executing the `CrearCoach` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CrearCoachData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CrearCoachData {
  coach_insert: Coach_Key;
}
```
### Using `CrearCoach`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, crearCoach, CrearCoachVariables } from '@dataconnect/generated';

// The `CrearCoach` mutation requires an argument of type `CrearCoachVariables`:
const crearCoachVars: CrearCoachVariables = {
  especialidad: ..., 
  aniosExperiencia: ..., 
};

// Call the `crearCoach()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await crearCoach(crearCoachVars);
// Variables can be defined inline as well.
const { data } = await crearCoach({ especialidad: ..., aniosExperiencia: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await crearCoach(dataConnect, crearCoachVars);

console.log(data.coach_insert);

// Or, you can use the `Promise` API.
crearCoach(crearCoachVars).then((response) => {
  const data = response.data;
  console.log(data.coach_insert);
});
```

### Using `CrearCoach`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, crearCoachRef, CrearCoachVariables } from '@dataconnect/generated';

// The `CrearCoach` mutation requires an argument of type `CrearCoachVariables`:
const crearCoachVars: CrearCoachVariables = {
  especialidad: ..., 
  aniosExperiencia: ..., 
};

// Call the `crearCoachRef()` function to get a reference to the mutation.
const ref = crearCoachRef(crearCoachVars);
// Variables can be defined inline as well.
const ref = crearCoachRef({ especialidad: ..., aniosExperiencia: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = crearCoachRef(dataConnect, crearCoachVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.coach_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.coach_insert);
});
```

## CrearNutriologo
You can execute the `CrearNutriologo` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
crearNutriologo(vars: CrearNutriologoVariables): MutationPromise<CrearNutriologoData, CrearNutriologoVariables>;

interface CrearNutriologoRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearNutriologoVariables): MutationRef<CrearNutriologoData, CrearNutriologoVariables>;
}
export const crearNutriologoRef: CrearNutriologoRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
crearNutriologo(dc: DataConnect, vars: CrearNutriologoVariables): MutationPromise<CrearNutriologoData, CrearNutriologoVariables>;

interface CrearNutriologoRef {
  ...
  (dc: DataConnect, vars: CrearNutriologoVariables): MutationRef<CrearNutriologoData, CrearNutriologoVariables>;
}
export const crearNutriologoRef: CrearNutriologoRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the crearNutriologoRef:
```typescript
const name = crearNutriologoRef.operationName;
console.log(name);
```

### Variables
The `CrearNutriologo` mutation requires an argument of type `CrearNutriologoVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CrearNutriologoVariables {
  enfoque: string;
  cedulaProfesional: string;
}
```
### Return Type
Recall that executing the `CrearNutriologo` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CrearNutriologoData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CrearNutriologoData {
  nutriologo_insert: Nutriologo_Key;
}
```
### Using `CrearNutriologo`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, crearNutriologo, CrearNutriologoVariables } from '@dataconnect/generated';

// The `CrearNutriologo` mutation requires an argument of type `CrearNutriologoVariables`:
const crearNutriologoVars: CrearNutriologoVariables = {
  enfoque: ..., 
  cedulaProfesional: ..., 
};

// Call the `crearNutriologo()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await crearNutriologo(crearNutriologoVars);
// Variables can be defined inline as well.
const { data } = await crearNutriologo({ enfoque: ..., cedulaProfesional: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await crearNutriologo(dataConnect, crearNutriologoVars);

console.log(data.nutriologo_insert);

// Or, you can use the `Promise` API.
crearNutriologo(crearNutriologoVars).then((response) => {
  const data = response.data;
  console.log(data.nutriologo_insert);
});
```

### Using `CrearNutriologo`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, crearNutriologoRef, CrearNutriologoVariables } from '@dataconnect/generated';

// The `CrearNutriologo` mutation requires an argument of type `CrearNutriologoVariables`:
const crearNutriologoVars: CrearNutriologoVariables = {
  enfoque: ..., 
  cedulaProfesional: ..., 
};

// Call the `crearNutriologoRef()` function to get a reference to the mutation.
const ref = crearNutriologoRef(crearNutriologoVars);
// Variables can be defined inline as well.
const ref = crearNutriologoRef({ enfoque: ..., cedulaProfesional: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = crearNutriologoRef(dataConnect, crearNutriologoVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.nutriologo_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.nutriologo_insert);
});
```

## CrearCliente
You can execute the `CrearCliente` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
crearCliente(vars?: CrearClienteVariables): MutationPromise<CrearClienteData, CrearClienteVariables>;

interface CrearClienteRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars?: CrearClienteVariables): MutationRef<CrearClienteData, CrearClienteVariables>;
}
export const crearClienteRef: CrearClienteRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
crearCliente(dc: DataConnect, vars?: CrearClienteVariables): MutationPromise<CrearClienteData, CrearClienteVariables>;

interface CrearClienteRef {
  ...
  (dc: DataConnect, vars?: CrearClienteVariables): MutationRef<CrearClienteData, CrearClienteVariables>;
}
export const crearClienteRef: CrearClienteRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the crearClienteRef:
```typescript
const name = crearClienteRef.operationName;
console.log(name);
```

### Variables
The `CrearCliente` mutation has an optional argument of type `CrearClienteVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CrearClienteVariables {
  coachId?: UUIDString | null;
  nutriologoId?: UUIDString | null;
  fechaNacimiento?: DateString | null;
  altura?: number | null;
}
```
### Return Type
Recall that executing the `CrearCliente` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CrearClienteData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CrearClienteData {
  cliente_insert: Cliente_Key;
}
```
### Using `CrearCliente`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, crearCliente, CrearClienteVariables } from '@dataconnect/generated';

// The `CrearCliente` mutation has an optional argument of type `CrearClienteVariables`:
const crearClienteVars: CrearClienteVariables = {
  coachId: ..., // optional
  nutriologoId: ..., // optional
  fechaNacimiento: ..., // optional
  altura: ..., // optional
};

// Call the `crearCliente()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await crearCliente(crearClienteVars);
// Variables can be defined inline as well.
const { data } = await crearCliente({ coachId: ..., nutriologoId: ..., fechaNacimiento: ..., altura: ..., });
// Since all variables are optional for this mutation, you can omit the `CrearClienteVariables` argument.
const { data } = await crearCliente();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await crearCliente(dataConnect, crearClienteVars);

console.log(data.cliente_insert);

// Or, you can use the `Promise` API.
crearCliente(crearClienteVars).then((response) => {
  const data = response.data;
  console.log(data.cliente_insert);
});
```

### Using `CrearCliente`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, crearClienteRef, CrearClienteVariables } from '@dataconnect/generated';

// The `CrearCliente` mutation has an optional argument of type `CrearClienteVariables`:
const crearClienteVars: CrearClienteVariables = {
  coachId: ..., // optional
  nutriologoId: ..., // optional
  fechaNacimiento: ..., // optional
  altura: ..., // optional
};

// Call the `crearClienteRef()` function to get a reference to the mutation.
const ref = crearClienteRef(crearClienteVars);
// Variables can be defined inline as well.
const ref = crearClienteRef({ coachId: ..., nutriologoId: ..., fechaNacimiento: ..., altura: ..., });
// Since all variables are optional for this mutation, you can omit the `CrearClienteVariables` argument.
const ref = crearClienteRef();

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = crearClienteRef(dataConnect, crearClienteVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.cliente_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.cliente_insert);
});
```

## RegistrarProgreso
You can execute the `RegistrarProgreso` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
registrarProgreso(vars: RegistrarProgresoVariables): MutationPromise<RegistrarProgresoData, RegistrarProgresoVariables>;

interface RegistrarProgresoRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: RegistrarProgresoVariables): MutationRef<RegistrarProgresoData, RegistrarProgresoVariables>;
}
export const registrarProgresoRef: RegistrarProgresoRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
registrarProgreso(dc: DataConnect, vars: RegistrarProgresoVariables): MutationPromise<RegistrarProgresoData, RegistrarProgresoVariables>;

interface RegistrarProgresoRef {
  ...
  (dc: DataConnect, vars: RegistrarProgresoVariables): MutationRef<RegistrarProgresoData, RegistrarProgresoVariables>;
}
export const registrarProgresoRef: RegistrarProgresoRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the registrarProgresoRef:
```typescript
const name = registrarProgresoRef.operationName;
console.log(name);
```

### Variables
The `RegistrarProgreso` mutation requires an argument of type `RegistrarProgresoVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface RegistrarProgresoVariables {
  clienteId: UUIDString;
  peso: number;
  imc: number;
}
```
### Return Type
Recall that executing the `RegistrarProgreso` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `RegistrarProgresoData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface RegistrarProgresoData {
  progreso_insert: Progreso_Key;
}
```
### Using `RegistrarProgreso`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, registrarProgreso, RegistrarProgresoVariables } from '@dataconnect/generated';

// The `RegistrarProgreso` mutation requires an argument of type `RegistrarProgresoVariables`:
const registrarProgresoVars: RegistrarProgresoVariables = {
  clienteId: ..., 
  peso: ..., 
  imc: ..., 
};

// Call the `registrarProgreso()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await registrarProgreso(registrarProgresoVars);
// Variables can be defined inline as well.
const { data } = await registrarProgreso({ clienteId: ..., peso: ..., imc: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await registrarProgreso(dataConnect, registrarProgresoVars);

console.log(data.progreso_insert);

// Or, you can use the `Promise` API.
registrarProgreso(registrarProgresoVars).then((response) => {
  const data = response.data;
  console.log(data.progreso_insert);
});
```

### Using `RegistrarProgreso`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, registrarProgresoRef, RegistrarProgresoVariables } from '@dataconnect/generated';

// The `RegistrarProgreso` mutation requires an argument of type `RegistrarProgresoVariables`:
const registrarProgresoVars: RegistrarProgresoVariables = {
  clienteId: ..., 
  peso: ..., 
  imc: ..., 
};

// Call the `registrarProgresoRef()` function to get a reference to the mutation.
const ref = registrarProgresoRef(registrarProgresoVars);
// Variables can be defined inline as well.
const ref = registrarProgresoRef({ clienteId: ..., peso: ..., imc: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = registrarProgresoRef(dataConnect, registrarProgresoVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.progreso_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.progreso_insert);
});
```

## CrearEjercicio
You can execute the `CrearEjercicio` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
crearEjercicio(vars: CrearEjercicioVariables): MutationPromise<CrearEjercicioData, CrearEjercicioVariables>;

interface CrearEjercicioRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearEjercicioVariables): MutationRef<CrearEjercicioData, CrearEjercicioVariables>;
}
export const crearEjercicioRef: CrearEjercicioRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
crearEjercicio(dc: DataConnect, vars: CrearEjercicioVariables): MutationPromise<CrearEjercicioData, CrearEjercicioVariables>;

interface CrearEjercicioRef {
  ...
  (dc: DataConnect, vars: CrearEjercicioVariables): MutationRef<CrearEjercicioData, CrearEjercicioVariables>;
}
export const crearEjercicioRef: CrearEjercicioRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the crearEjercicioRef:
```typescript
const name = crearEjercicioRef.operationName;
console.log(name);
```

### Variables
The `CrearEjercicio` mutation requires an argument of type `CrearEjercicioVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CrearEjercicioVariables {
  nombre: string;
  descripcion?: string | null;
  grupoMuscular?: string | null;
}
```
### Return Type
Recall that executing the `CrearEjercicio` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CrearEjercicioData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CrearEjercicioData {
  ejercicio_insert: Ejercicio_Key;
}
```
### Using `CrearEjercicio`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, crearEjercicio, CrearEjercicioVariables } from '@dataconnect/generated';

// The `CrearEjercicio` mutation requires an argument of type `CrearEjercicioVariables`:
const crearEjercicioVars: CrearEjercicioVariables = {
  nombre: ..., 
  descripcion: ..., // optional
  grupoMuscular: ..., // optional
};

// Call the `crearEjercicio()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await crearEjercicio(crearEjercicioVars);
// Variables can be defined inline as well.
const { data } = await crearEjercicio({ nombre: ..., descripcion: ..., grupoMuscular: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await crearEjercicio(dataConnect, crearEjercicioVars);

console.log(data.ejercicio_insert);

// Or, you can use the `Promise` API.
crearEjercicio(crearEjercicioVars).then((response) => {
  const data = response.data;
  console.log(data.ejercicio_insert);
});
```

### Using `CrearEjercicio`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, crearEjercicioRef, CrearEjercicioVariables } from '@dataconnect/generated';

// The `CrearEjercicio` mutation requires an argument of type `CrearEjercicioVariables`:
const crearEjercicioVars: CrearEjercicioVariables = {
  nombre: ..., 
  descripcion: ..., // optional
  grupoMuscular: ..., // optional
};

// Call the `crearEjercicioRef()` function to get a reference to the mutation.
const ref = crearEjercicioRef(crearEjercicioVars);
// Variables can be defined inline as well.
const ref = crearEjercicioRef({ nombre: ..., descripcion: ..., grupoMuscular: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = crearEjercicioRef(dataConnect, crearEjercicioVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.ejercicio_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.ejercicio_insert);
});
```

## CrearRutina
You can execute the `CrearRutina` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
crearRutina(vars: CrearRutinaVariables): MutationPromise<CrearRutinaData, CrearRutinaVariables>;

interface CrearRutinaRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearRutinaVariables): MutationRef<CrearRutinaData, CrearRutinaVariables>;
}
export const crearRutinaRef: CrearRutinaRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
crearRutina(dc: DataConnect, vars: CrearRutinaVariables): MutationPromise<CrearRutinaData, CrearRutinaVariables>;

interface CrearRutinaRef {
  ...
  (dc: DataConnect, vars: CrearRutinaVariables): MutationRef<CrearRutinaData, CrearRutinaVariables>;
}
export const crearRutinaRef: CrearRutinaRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the crearRutinaRef:
```typescript
const name = crearRutinaRef.operationName;
console.log(name);
```

### Variables
The `CrearRutina` mutation requires an argument of type `CrearRutinaVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CrearRutinaVariables {
  clienteId: UUIDString;
  nombre: string;
  descripcion?: string | null;
  fechaFin?: DateString | null;
}
```
### Return Type
Recall that executing the `CrearRutina` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CrearRutinaData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CrearRutinaData {
  rutina_insert: Rutina_Key;
}
```
### Using `CrearRutina`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, crearRutina, CrearRutinaVariables } from '@dataconnect/generated';

// The `CrearRutina` mutation requires an argument of type `CrearRutinaVariables`:
const crearRutinaVars: CrearRutinaVariables = {
  clienteId: ..., 
  nombre: ..., 
  descripcion: ..., // optional
  fechaFin: ..., // optional
};

// Call the `crearRutina()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await crearRutina(crearRutinaVars);
// Variables can be defined inline as well.
const { data } = await crearRutina({ clienteId: ..., nombre: ..., descripcion: ..., fechaFin: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await crearRutina(dataConnect, crearRutinaVars);

console.log(data.rutina_insert);

// Or, you can use the `Promise` API.
crearRutina(crearRutinaVars).then((response) => {
  const data = response.data;
  console.log(data.rutina_insert);
});
```

### Using `CrearRutina`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, crearRutinaRef, CrearRutinaVariables } from '@dataconnect/generated';

// The `CrearRutina` mutation requires an argument of type `CrearRutinaVariables`:
const crearRutinaVars: CrearRutinaVariables = {
  clienteId: ..., 
  nombre: ..., 
  descripcion: ..., // optional
  fechaFin: ..., // optional
};

// Call the `crearRutinaRef()` function to get a reference to the mutation.
const ref = crearRutinaRef(crearRutinaVars);
// Variables can be defined inline as well.
const ref = crearRutinaRef({ clienteId: ..., nombre: ..., descripcion: ..., fechaFin: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = crearRutinaRef(dataConnect, crearRutinaVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.rutina_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.rutina_insert);
});
```

## AgregarEjercicioARutina
You can execute the `AgregarEjercicioARutina` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
agregarEjercicioARutina(vars: AgregarEjercicioARutinaVariables): MutationPromise<AgregarEjercicioARutinaData, AgregarEjercicioARutinaVariables>;

interface AgregarEjercicioARutinaRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: AgregarEjercicioARutinaVariables): MutationRef<AgregarEjercicioARutinaData, AgregarEjercicioARutinaVariables>;
}
export const agregarEjercicioARutinaRef: AgregarEjercicioARutinaRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
agregarEjercicioARutina(dc: DataConnect, vars: AgregarEjercicioARutinaVariables): MutationPromise<AgregarEjercicioARutinaData, AgregarEjercicioARutinaVariables>;

interface AgregarEjercicioARutinaRef {
  ...
  (dc: DataConnect, vars: AgregarEjercicioARutinaVariables): MutationRef<AgregarEjercicioARutinaData, AgregarEjercicioARutinaVariables>;
}
export const agregarEjercicioARutinaRef: AgregarEjercicioARutinaRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the agregarEjercicioARutinaRef:
```typescript
const name = agregarEjercicioARutinaRef.operationName;
console.log(name);
```

### Variables
The `AgregarEjercicioARutina` mutation requires an argument of type `AgregarEjercicioARutinaVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface AgregarEjercicioARutinaVariables {
  rutinaId: UUIDString;
  ejercicioId: UUIDString;
  series?: number | null;
  repeticiones?: number | null;
  descansoSegundos?: number | null;
  orden?: number | null;
}
```
### Return Type
Recall that executing the `AgregarEjercicioARutina` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `AgregarEjercicioARutinaData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface AgregarEjercicioARutinaData {
  rutinaEjercicio_insert: RutinaEjercicio_Key;
}
```
### Using `AgregarEjercicioARutina`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, agregarEjercicioARutina, AgregarEjercicioARutinaVariables } from '@dataconnect/generated';

// The `AgregarEjercicioARutina` mutation requires an argument of type `AgregarEjercicioARutinaVariables`:
const agregarEjercicioARutinaVars: AgregarEjercicioARutinaVariables = {
  rutinaId: ..., 
  ejercicioId: ..., 
  series: ..., // optional
  repeticiones: ..., // optional
  descansoSegundos: ..., // optional
  orden: ..., // optional
};

// Call the `agregarEjercicioARutina()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await agregarEjercicioARutina(agregarEjercicioARutinaVars);
// Variables can be defined inline as well.
const { data } = await agregarEjercicioARutina({ rutinaId: ..., ejercicioId: ..., series: ..., repeticiones: ..., descansoSegundos: ..., orden: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await agregarEjercicioARutina(dataConnect, agregarEjercicioARutinaVars);

console.log(data.rutinaEjercicio_insert);

// Or, you can use the `Promise` API.
agregarEjercicioARutina(agregarEjercicioARutinaVars).then((response) => {
  const data = response.data;
  console.log(data.rutinaEjercicio_insert);
});
```

### Using `AgregarEjercicioARutina`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, agregarEjercicioARutinaRef, AgregarEjercicioARutinaVariables } from '@dataconnect/generated';

// The `AgregarEjercicioARutina` mutation requires an argument of type `AgregarEjercicioARutinaVariables`:
const agregarEjercicioARutinaVars: AgregarEjercicioARutinaVariables = {
  rutinaId: ..., 
  ejercicioId: ..., 
  series: ..., // optional
  repeticiones: ..., // optional
  descansoSegundos: ..., // optional
  orden: ..., // optional
};

// Call the `agregarEjercicioARutinaRef()` function to get a reference to the mutation.
const ref = agregarEjercicioARutinaRef(agregarEjercicioARutinaVars);
// Variables can be defined inline as well.
const ref = agregarEjercicioARutinaRef({ rutinaId: ..., ejercicioId: ..., series: ..., repeticiones: ..., descansoSegundos: ..., orden: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = agregarEjercicioARutinaRef(dataConnect, agregarEjercicioARutinaVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.rutinaEjercicio_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.rutinaEjercicio_insert);
});
```

## CrearPlanNutricional
You can execute the `CrearPlanNutricional` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
crearPlanNutricional(vars: CrearPlanNutricionalVariables): MutationPromise<CrearPlanNutricionalData, CrearPlanNutricionalVariables>;

interface CrearPlanNutricionalRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearPlanNutricionalVariables): MutationRef<CrearPlanNutricionalData, CrearPlanNutricionalVariables>;
}
export const crearPlanNutricionalRef: CrearPlanNutricionalRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
crearPlanNutricional(dc: DataConnect, vars: CrearPlanNutricionalVariables): MutationPromise<CrearPlanNutricionalData, CrearPlanNutricionalVariables>;

interface CrearPlanNutricionalRef {
  ...
  (dc: DataConnect, vars: CrearPlanNutricionalVariables): MutationRef<CrearPlanNutricionalData, CrearPlanNutricionalVariables>;
}
export const crearPlanNutricionalRef: CrearPlanNutricionalRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the crearPlanNutricionalRef:
```typescript
const name = crearPlanNutricionalRef.operationName;
console.log(name);
```

### Variables
The `CrearPlanNutricional` mutation requires an argument of type `CrearPlanNutricionalVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CrearPlanNutricionalVariables {
  clienteId: UUIDString;
  descripcion: string;
  fechaFin?: DateString | null;
}
```
### Return Type
Recall that executing the `CrearPlanNutricional` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CrearPlanNutricionalData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CrearPlanNutricionalData {
  planNutricional_insert: PlanNutricional_Key;
}
```
### Using `CrearPlanNutricional`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, crearPlanNutricional, CrearPlanNutricionalVariables } from '@dataconnect/generated';

// The `CrearPlanNutricional` mutation requires an argument of type `CrearPlanNutricionalVariables`:
const crearPlanNutricionalVars: CrearPlanNutricionalVariables = {
  clienteId: ..., 
  descripcion: ..., 
  fechaFin: ..., // optional
};

// Call the `crearPlanNutricional()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await crearPlanNutricional(crearPlanNutricionalVars);
// Variables can be defined inline as well.
const { data } = await crearPlanNutricional({ clienteId: ..., descripcion: ..., fechaFin: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await crearPlanNutricional(dataConnect, crearPlanNutricionalVars);

console.log(data.planNutricional_insert);

// Or, you can use the `Promise` API.
crearPlanNutricional(crearPlanNutricionalVars).then((response) => {
  const data = response.data;
  console.log(data.planNutricional_insert);
});
```

### Using `CrearPlanNutricional`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, crearPlanNutricionalRef, CrearPlanNutricionalVariables } from '@dataconnect/generated';

// The `CrearPlanNutricional` mutation requires an argument of type `CrearPlanNutricionalVariables`:
const crearPlanNutricionalVars: CrearPlanNutricionalVariables = {
  clienteId: ..., 
  descripcion: ..., 
  fechaFin: ..., // optional
};

// Call the `crearPlanNutricionalRef()` function to get a reference to the mutation.
const ref = crearPlanNutricionalRef(crearPlanNutricionalVars);
// Variables can be defined inline as well.
const ref = crearPlanNutricionalRef({ clienteId: ..., descripcion: ..., fechaFin: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = crearPlanNutricionalRef(dataConnect, crearPlanNutricionalVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.planNutricional_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.planNutricional_insert);
});
```

## CrearTicket
You can execute the `CrearTicket` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
crearTicket(vars: CrearTicketVariables): MutationPromise<CrearTicketData, CrearTicketVariables>;

interface CrearTicketRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CrearTicketVariables): MutationRef<CrearTicketData, CrearTicketVariables>;
}
export const crearTicketRef: CrearTicketRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
crearTicket(dc: DataConnect, vars: CrearTicketVariables): MutationPromise<CrearTicketData, CrearTicketVariables>;

interface CrearTicketRef {
  ...
  (dc: DataConnect, vars: CrearTicketVariables): MutationRef<CrearTicketData, CrearTicketVariables>;
}
export const crearTicketRef: CrearTicketRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the crearTicketRef:
```typescript
const name = crearTicketRef.operationName;
console.log(name);
```

### Variables
The `CrearTicket` mutation requires an argument of type `CrearTicketVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CrearTicketVariables {
  asunto: string;
}
```
### Return Type
Recall that executing the `CrearTicket` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CrearTicketData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CrearTicketData {
  ticket_insert: Ticket_Key;
}
```
### Using `CrearTicket`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, crearTicket, CrearTicketVariables } from '@dataconnect/generated';

// The `CrearTicket` mutation requires an argument of type `CrearTicketVariables`:
const crearTicketVars: CrearTicketVariables = {
  asunto: ..., 
};

// Call the `crearTicket()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await crearTicket(crearTicketVars);
// Variables can be defined inline as well.
const { data } = await crearTicket({ asunto: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await crearTicket(dataConnect, crearTicketVars);

console.log(data.ticket_insert);

// Or, you can use the `Promise` API.
crearTicket(crearTicketVars).then((response) => {
  const data = response.data;
  console.log(data.ticket_insert);
});
```

### Using `CrearTicket`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, crearTicketRef, CrearTicketVariables } from '@dataconnect/generated';

// The `CrearTicket` mutation requires an argument of type `CrearTicketVariables`:
const crearTicketVars: CrearTicketVariables = {
  asunto: ..., 
};

// Call the `crearTicketRef()` function to get a reference to the mutation.
const ref = crearTicketRef(crearTicketVars);
// Variables can be defined inline as well.
const ref = crearTicketRef({ asunto: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = crearTicketRef(dataConnect, crearTicketVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.ticket_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.ticket_insert);
});
```

## ResponderTicket
You can execute the `ResponderTicket` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
responderTicket(vars: ResponderTicketVariables): MutationPromise<ResponderTicketData, ResponderTicketVariables>;

interface ResponderTicketRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: ResponderTicketVariables): MutationRef<ResponderTicketData, ResponderTicketVariables>;
}
export const responderTicketRef: ResponderTicketRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
responderTicket(dc: DataConnect, vars: ResponderTicketVariables): MutationPromise<ResponderTicketData, ResponderTicketVariables>;

interface ResponderTicketRef {
  ...
  (dc: DataConnect, vars: ResponderTicketVariables): MutationRef<ResponderTicketData, ResponderTicketVariables>;
}
export const responderTicketRef: ResponderTicketRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the responderTicketRef:
```typescript
const name = responderTicketRef.operationName;
console.log(name);
```

### Variables
The `ResponderTicket` mutation requires an argument of type `ResponderTicketVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ResponderTicketVariables {
  ticketId: UUIDString;
  contenido: string;
}
```
### Return Type
Recall that executing the `ResponderTicket` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ResponderTicketData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ResponderTicketData {
  mensajeTicket_insert: MensajeTicket_Key;
}
```
### Using `ResponderTicket`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, responderTicket, ResponderTicketVariables } from '@dataconnect/generated';

// The `ResponderTicket` mutation requires an argument of type `ResponderTicketVariables`:
const responderTicketVars: ResponderTicketVariables = {
  ticketId: ..., 
  contenido: ..., 
};

// Call the `responderTicket()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await responderTicket(responderTicketVars);
// Variables can be defined inline as well.
const { data } = await responderTicket({ ticketId: ..., contenido: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await responderTicket(dataConnect, responderTicketVars);

console.log(data.mensajeTicket_insert);

// Or, you can use the `Promise` API.
responderTicket(responderTicketVars).then((response) => {
  const data = response.data;
  console.log(data.mensajeTicket_insert);
});
```

### Using `ResponderTicket`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, responderTicketRef, ResponderTicketVariables } from '@dataconnect/generated';

// The `ResponderTicket` mutation requires an argument of type `ResponderTicketVariables`:
const responderTicketVars: ResponderTicketVariables = {
  ticketId: ..., 
  contenido: ..., 
};

// Call the `responderTicketRef()` function to get a reference to the mutation.
const ref = responderTicketRef(responderTicketVars);
// Variables can be defined inline as well.
const ref = responderTicketRef({ ticketId: ..., contenido: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = responderTicketRef(dataConnect, responderTicketVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.mensajeTicket_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.mensajeTicket_insert);
});
```

## CambiarEstadoTicket
You can execute the `CambiarEstadoTicket` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
cambiarEstadoTicket(vars: CambiarEstadoTicketVariables): MutationPromise<CambiarEstadoTicketData, CambiarEstadoTicketVariables>;

interface CambiarEstadoTicketRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CambiarEstadoTicketVariables): MutationRef<CambiarEstadoTicketData, CambiarEstadoTicketVariables>;
}
export const cambiarEstadoTicketRef: CambiarEstadoTicketRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
cambiarEstadoTicket(dc: DataConnect, vars: CambiarEstadoTicketVariables): MutationPromise<CambiarEstadoTicketData, CambiarEstadoTicketVariables>;

interface CambiarEstadoTicketRef {
  ...
  (dc: DataConnect, vars: CambiarEstadoTicketVariables): MutationRef<CambiarEstadoTicketData, CambiarEstadoTicketVariables>;
}
export const cambiarEstadoTicketRef: CambiarEstadoTicketRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the cambiarEstadoTicketRef:
```typescript
const name = cambiarEstadoTicketRef.operationName;
console.log(name);
```

### Variables
The `CambiarEstadoTicket` mutation requires an argument of type `CambiarEstadoTicketVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CambiarEstadoTicketVariables {
  id: UUIDString;
  estado: EstadoTicket;
}
```
### Return Type
Recall that executing the `CambiarEstadoTicket` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CambiarEstadoTicketData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CambiarEstadoTicketData {
  ticket_update?: Ticket_Key | null;
}
```
### Using `CambiarEstadoTicket`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, cambiarEstadoTicket, CambiarEstadoTicketVariables } from '@dataconnect/generated';

// The `CambiarEstadoTicket` mutation requires an argument of type `CambiarEstadoTicketVariables`:
const cambiarEstadoTicketVars: CambiarEstadoTicketVariables = {
  id: ..., 
  estado: ..., 
};

// Call the `cambiarEstadoTicket()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await cambiarEstadoTicket(cambiarEstadoTicketVars);
// Variables can be defined inline as well.
const { data } = await cambiarEstadoTicket({ id: ..., estado: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await cambiarEstadoTicket(dataConnect, cambiarEstadoTicketVars);

console.log(data.ticket_update);

// Or, you can use the `Promise` API.
cambiarEstadoTicket(cambiarEstadoTicketVars).then((response) => {
  const data = response.data;
  console.log(data.ticket_update);
});
```

### Using `CambiarEstadoTicket`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, cambiarEstadoTicketRef, CambiarEstadoTicketVariables } from '@dataconnect/generated';

// The `CambiarEstadoTicket` mutation requires an argument of type `CambiarEstadoTicketVariables`:
const cambiarEstadoTicketVars: CambiarEstadoTicketVariables = {
  id: ..., 
  estado: ..., 
};

// Call the `cambiarEstadoTicketRef()` function to get a reference to the mutation.
const ref = cambiarEstadoTicketRef(cambiarEstadoTicketVars);
// Variables can be defined inline as well.
const ref = cambiarEstadoTicketRef({ id: ..., estado: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = cambiarEstadoTicketRef(dataConnect, cambiarEstadoTicketVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.ticket_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.ticket_update);
});
```

## EmitirCertificacion
You can execute the `EmitirCertificacion` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
emitirCertificacion(vars: EmitirCertificacionVariables): MutationPromise<EmitirCertificacionData, EmitirCertificacionVariables>;

interface EmitirCertificacionRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: EmitirCertificacionVariables): MutationRef<EmitirCertificacionData, EmitirCertificacionVariables>;
}
export const emitirCertificacionRef: EmitirCertificacionRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
emitirCertificacion(dc: DataConnect, vars: EmitirCertificacionVariables): MutationPromise<EmitirCertificacionData, EmitirCertificacionVariables>;

interface EmitirCertificacionRef {
  ...
  (dc: DataConnect, vars: EmitirCertificacionVariables): MutationRef<EmitirCertificacionData, EmitirCertificacionVariables>;
}
export const emitirCertificacionRef: EmitirCertificacionRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the emitirCertificacionRef:
```typescript
const name = emitirCertificacionRef.operationName;
console.log(name);
```

### Variables
The `EmitirCertificacion` mutation requires an argument of type `EmitirCertificacionVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface EmitirCertificacionVariables {
  usuarioId: string;
  titulo: string;
}
```
### Return Type
Recall that executing the `EmitirCertificacion` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `EmitirCertificacionData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface EmitirCertificacionData {
  certificacion_insert: Certificacion_Key;
}
```
### Using `EmitirCertificacion`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, emitirCertificacion, EmitirCertificacionVariables } from '@dataconnect/generated';

// The `EmitirCertificacion` mutation requires an argument of type `EmitirCertificacionVariables`:
const emitirCertificacionVars: EmitirCertificacionVariables = {
  usuarioId: ..., 
  titulo: ..., 
};

// Call the `emitirCertificacion()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await emitirCertificacion(emitirCertificacionVars);
// Variables can be defined inline as well.
const { data } = await emitirCertificacion({ usuarioId: ..., titulo: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await emitirCertificacion(dataConnect, emitirCertificacionVars);

console.log(data.certificacion_insert);

// Or, you can use the `Promise` API.
emitirCertificacion(emitirCertificacionVars).then((response) => {
  const data = response.data;
  console.log(data.certificacion_insert);
});
```

### Using `EmitirCertificacion`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, emitirCertificacionRef, EmitirCertificacionVariables } from '@dataconnect/generated';

// The `EmitirCertificacion` mutation requires an argument of type `EmitirCertificacionVariables`:
const emitirCertificacionVars: EmitirCertificacionVariables = {
  usuarioId: ..., 
  titulo: ..., 
};

// Call the `emitirCertificacionRef()` function to get a reference to the mutation.
const ref = emitirCertificacionRef(emitirCertificacionVars);
// Variables can be defined inline as well.
const ref = emitirCertificacionRef({ usuarioId: ..., titulo: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = emitirCertificacionRef(dataConnect, emitirCertificacionVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.certificacion_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.certificacion_insert);
});
```

