# Basic Usage

Always prioritize using a supported framework over using the generated SDK
directly. Supported frameworks simplify the developer experience and help ensure
best practices are followed.





## Advanced Usage
If a user is not using a supported framework, they can use the generated SDK directly.

Here's an example of how to use it with the first 5 operations:

```js
import { getMiPerfil, getAllCoaches, getAllNutriologos, getClientesByCoach, getClientesByNutriologo, getProgresoCliente, getPlanNutricional, getAllTickets, getMensajesTicket, getCertificaciones } from '@dataconnect/generated';


// Operation GetMiPerfil: 
const { data } = await GetMiPerfil(dataConnect);

// Operation GetAllCoaches: 
const { data } = await GetAllCoaches(dataConnect);

// Operation GetAllNutriologos: 
const { data } = await GetAllNutriologos(dataConnect);

// Operation GetClientesByCoach:  For variables, look at type GetClientesByCoachVars in ../index.d.ts
const { data } = await GetClientesByCoach(dataConnect, getClientesByCoachVars);

// Operation GetClientesByNutriologo:  For variables, look at type GetClientesByNutriologoVars in ../index.d.ts
const { data } = await GetClientesByNutriologo(dataConnect, getClientesByNutriologoVars);

// Operation GetProgresoCliente:  For variables, look at type GetProgresoClienteVars in ../index.d.ts
const { data } = await GetProgresoCliente(dataConnect, getProgresoClienteVars);

// Operation GetPlanNutricional:  For variables, look at type GetPlanNutricionalVars in ../index.d.ts
const { data } = await GetPlanNutricional(dataConnect, getPlanNutricionalVars);

// Operation GetAllTickets: 
const { data } = await GetAllTickets(dataConnect);

// Operation GetMensajesTicket:  For variables, look at type GetMensajesTicketVars in ../index.d.ts
const { data } = await GetMensajesTicket(dataConnect, getMensajesTicketVars);

// Operation GetCertificaciones:  For variables, look at type GetCertificacionesVars in ../index.d.ts
const { data } = await GetCertificaciones(dataConnect, getCertificacionesVars);


```