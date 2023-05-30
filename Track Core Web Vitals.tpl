﻿___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Track Core Web Vitals",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Etiqueta empleada para registrar los Core Web Vitals y enviarlos juntos en un push del dataLayer una vez se han recogido todos.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "GROUP",
    "name": "cwvChecks",
    "displayName": "CWV to add in the push",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "trackFID",
        "checkboxText": "FID",
        "simpleValueType": true,
        "help": "El FID (First Input Delay) es un CWV que mide la diferencia de tiempo entre que el usuario intenta interaccionar por primera vez con la página y que esta responde a esa interacción tal y como debería."
      },
      {
        "type": "CHECKBOX",
        "name": "trackCLS",
        "checkboxText": "CLS",
        "simpleValueType": true,
        "help": "El CLS (Cumulative Layout Shift) es un CWV que mide la estabilidad visual de la página, asignando una puntuación en base a la frecuencia con la que los usuarios experimentan cambios visuales, como elementos de la página siendo desplazados durante la navegación en esta."
      },
      {
        "type": "CHECKBOX",
        "name": "trackLCP",
        "checkboxText": "LCP",
        "simpleValueType": true,
        "help": "El LCP (Largest Contenful Paint) es un CWV que se corresponde con el tiempo de carga que necesita el mayor elemento de contenido de la parte superior de la página desde que la página empieza a cargar hasta que dicho elemento ya se encuentra completamente cargado."
      },
      {
        "type": "CHECKBOX",
        "name": "trackFCP",
        "checkboxText": "FCP",
        "simpleValueType": true,
        "help": "El FCP (First Contentful Paint) es un CWV que mide el tiempo entre que el usuario accede a la página y que se le muestra el primer elemento visual de esta."
      },
      {
        "type": "CHECKBOX",
        "name": "trackTTFB",
        "checkboxText": "TTFB",
        "simpleValueType": true,
        "help": "El TTFB (Time To First Byte) es un CWV que representa la diferencia de tiempo entre que el usuario realiza una petición a la página y le llega el primer byte de información de la respuesta."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "tagConfig",
    "displayName": "Configuration options",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "includeRoundedValue",
        "checkboxText": "Incluir valor redondeado en la información de cada CWV",
        "simpleValueType": true,
        "help": "Marcar si se desea que dentro de la información de cada CWV se añada un campo con el valor redondeado."
      },
      {
        "type": "CHECKBOX",
        "name": "sendDataWhenIsReady",
        "checkboxText": "Realizar el push del dataLayer automáticamente al recopilar todos los CWV deseados",
        "simpleValueType": true,
        "help": "Al marcarse esta opción, se mandarán automáticamente los datos en el momento en el que todos los CWV deseados ya se encuentren registrados."
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Load template APIs
const copyFromWindow = require('copyFromWindow');
const setInWindow = require('setInWindow');
const createQueue = require('createQueue');
const injectScript = require('injectScript');
const log = require('logToConsole');
const Math = require('Math');


// Initialize variables
const dataLayerPush = createQueue('dataLayer');
const dlObj = {event: 'ikauecwv', webVitalsMeasurement: {}};
let dataSent = false;
setInWindow('cwvDataSent', false, true);


// Helper to update the JS variable storing the event data to send
const updateEventData = () => {
  log("Still waiting for all data to be collected. Current Datalayer value:");
  log(dlObj);
  setInWindow('cwvEvent', dlObj, true);
};


// Helper for failure handling
const fail = msg => {
  log(msg);
  data.gtmOnFailure();
};


// Add the received CWV data to the object that will be pushed into the dataLayer
const process = obj => {
  // Only if the CWV data has not been sent yet and the passed CWV has not been stored earlier
  if (!dataSent && !dlObj.webVitalsMeasurement[obj.name]) {
    const cwvObj = {
      name: obj.name,
      id: obj.id,
      value: obj.value,
    };
    
    // If option is checked, include rounded value
    if (data.includeRoundedValue)
      cwvObj.valueRounded = Math.round(obj.name === 'CLS' ? obj.value * 1000 : obj.value);
     
    // Add the recently created CWV object to the event object that holds all the CWV
    dlObj.webVitalsMeasurement[obj.name] = cwvObj;
  
    if (data.sendDataWhenIsReady) { // If it is checked...
      // ... check that all the desired CWV are stored ...
      if ((data.trackFID == !!dlObj.webVitalsMeasurement.FID) &&
          (data.trackCLS == !!dlObj.webVitalsMeasurement.CLS) &&
          (data.trackLCP == !!dlObj.webVitalsMeasurement.LCP) &&
          (data.trackTTFB == !!dlObj.webVitalsMeasurement.TTFB) &&
          (data.trackFCP == !!dlObj.webVitalsMeasurement.FCP)) {          
            // ... make the push with the data
            dataLayerPush(dlObj);
            log("All data collected. Datalayer value:");
            log(dlObj);
      
            // Update status variables to avoid sending the data multiple times.
            setInWindow('cwvDataSent', true, true);
            dataSent = true;
          } else {updateEventData();} // if at least one CWV is missing, just update the JS variable
    } else {updateEventData();} // if the option is checked, also just update the JS variable
  } 
};

// Set the handlers
const setMilestones = () => {
    const wv = copyFromWindow('webVitals');
    if (!wv) {return fail('[GTM / Core Web Vitals]: window.webVitals failed to load.');}
    // Register just the selected CWV
    if (data.trackFID) {wv.getFID(process);}
    if (data.trackCLS) {wv.getCLS(process);}
    if (data.trackLCP) {wv.getLCP(process);}
    if (data.trackTTFB) {wv.getTTFB(process);} 
    if (data.trackFCP) {wv.getFCP(process);} 
    data.gtmOnSuccess();  
};

// Load the library
injectScript('https://unpkg.com/web-vitals/dist/web-vitals.iife.js', setMilestones, data.gtmOnFailure, 'web-vitals');


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "dataLayer"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "webVitals"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "cwvEvent"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "cwvDataSent"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "inject_script",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://unpkg.com/web-vitals/dist/web-vitals.iife.js"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 16/12/2021 10:27:08


