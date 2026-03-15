# Basic Usage

Always prioritize using a supported framework over using the generated SDK
directly. Supported frameworks simplify the developer experience and help ensure
best practices are followed.





## Advanced Usage
If a user is not using a supported framework, they can use the generated SDK directly.

Here's an example of how to use it with the first 5 operations:

```js
import { createUsuario, crearPerfil, crearCoach, crearNutriologo, crearCliente, registrarProgreso, crearEjercicio, crearRutina, agregarEjercicioARutina, crearPlanNutricional } from '@dataconnect/generated';


// Operation CreateUsuario:  For variables, look at type CreateUsuarioVars in ../index.d.ts
const { data } = await CreateUsuario(dataConnect, createUsuarioVars);

// Operation CrearPerfil:  For variables, look at type CrearPerfilVars in ../index.d.ts
const { data } = await CrearPerfil(dataConnect, crearPerfilVars);

// Operation CrearCoach:  For variables, look at type CrearCoachVars in ../index.d.ts
const { data } = await CrearCoach(dataConnect, crearCoachVars);

// Operation CrearNutriologo:  For variables, look at type CrearNutriologoVars in ../index.d.ts
const { data } = await CrearNutriologo(dataConnect, crearNutriologoVars);

// Operation CrearCliente:  For variables, look at type CrearClienteVars in ../index.d.ts
const { data } = await CrearCliente(dataConnect, crearClienteVars);

// Operation RegistrarProgreso:  For variables, look at type RegistrarProgresoVars in ../index.d.ts
const { data } = await RegistrarProgreso(dataConnect, registrarProgresoVars);

// Operation CrearEjercicio:  For variables, look at type CrearEjercicioVars in ../index.d.ts
const { data } = await CrearEjercicio(dataConnect, crearEjercicioVars);

// Operation CrearRutina:  For variables, look at type CrearRutinaVars in ../index.d.ts
const { data } = await CrearRutina(dataConnect, crearRutinaVars);

// Operation AgregarEjercicioARutina:  For variables, look at type AgregarEjercicioARutinaVars in ../index.d.ts
const { data } = await AgregarEjercicioARutina(dataConnect, agregarEjercicioARutinaVars);

// Operation CrearPlanNutricional:  For variables, look at type CrearPlanNutricionalVars in ../index.d.ts
const { data } = await CrearPlanNutricional(dataConnect, crearPlanNutricionalVars);


```