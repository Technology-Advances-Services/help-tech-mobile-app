import 'package:flutter/material.dart';

import '../../Shared/widgets/unauthorized.dart';

class TermsAndConditions extends StatelessWidget {

  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('')
      ),
      body: Column(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        'Términos y Condiciones de Uso',
                        style: TextStyle(fontSize: 20,
                            fontWeight: FontWeight.bold)
                      ),
                      SizedBox(height: 16),

                      Text(
                        'Al acceder, registrarse o utilizar la aplicación '
                        'HelpTech, el Usuario declara que ha leído, '
                        'comprendido y aceptado íntegramente el presente '
                        'Acuerdo de Servicio. Este constituye un contrato '
                        'legalmente vinculante entre el Usuario y '
                        'Technology Advances Services, titular y operadora '
                        'de la plataforma.',
                        textAlign: TextAlign.justify
                      ),
                      SizedBox(height: 16),

                      Text(
                        'HelpTech es una plataforma provista bajo el modelo '
                        'SaaS (Software como Servicio), que permite a los '
                        'Usuarios acceder a herramientas digitales para la '
                        'gestión, solicitud y oferta de servicios técnicos '
                        'especializados. La Empresa otorga una licencia '
                        'limitada, no exclusiva, intransferible y revocable '
                        'para el uso de la plataforma conforme a este acuerdo.',
                        textAlign: TextAlign.justify
                      ),
                      SizedBox(height: 16),

                      Text(
                        'El uso completo de la plataforma requiere la '
                        'creación de una cuenta mediante el registro de '
                        'datos personales veraces y actualizados, incluyendo '
                        'DNI, nombre completo, correo electrónico y número '
                        'de teléfono móvil. El Usuario es responsable de '
                        'mantener la confidencialidad de sus '
                        'credenciales de acceso.',
                        textAlign: TextAlign.justify
                      ),
                      SizedBox(height: 16),

                      Text(
                        'El acceso a los servicios está condicionado a la '
                        'suscripción de un plan de servicio. Los detalles '
                        'de cada plan (precio, duración y características) '
                        'estarán claramente especificados dentro de la '
                        'aplicación. El pago se efectúa exclusivamente '
                        'mediante tarjeta de crédito o débito a través de '
                        'pasarelas de pago seguras.',
                        textAlign: TextAlign.justify
                      ),
                      SizedBox(height: 16),

                      Text(
                        'Todos los derechos de propiedad intelectual '
                        'relacionados con la plataforma, incluyendo el '
                        'código fuente, diseño, funcionalidades y contenido, '
                        'son de exclusiva propiedad de '
                        'Technology Advances Services. Nada en este acuerdo '
                        'transfiere derechos de propiedad al Usuario.',
                        textAlign: TextAlign.justify
                      ),
                      SizedBox(height: 16),

                      Text(
                        'La aplicación y su concepto original son propiedad '
                        'de la empresa Technology Advances Services, titular '
                        'exclusivo de todos los derechos de autor, propiedad '
                        'intelectual y responsabilidad comercial. Cualquier '
                        'uso no autorizado de su contenido será considerado '
                        'una infracción conforme a la legislación vigente.',
                        textAlign: TextAlign.justify
                      ),
                      SizedBox(height: 16),

                      Text(
                        'La Empresa se compromete a garantizar la privacidad y '
                        'protección de los datos personales suministrados '
                        'por los Usuarios. Esta información será tratada '
                        'con estricta confidencialidad y protegida mediante '
                        'mecanismos de seguridad adecuados, incluyendo la '
                        'implementación de tokens de '
                        'autenticación en el backend.',
                        textAlign: TextAlign.justify
                      ),
                      SizedBox(height: 16),

                      Text(
                        'Para consultas, quejas o solicitudes relacionadas con '
                        'este Acuerdo de Servicio, los Usuarios pueden '
                        'contactarnos a través del correo electrónico: '
                        'technologyadvancesservices@gmail.com.',
                        textAlign: TextAlign.justify
                      ),
                      SizedBox(height: 16),

                      Text(
                        'Modificaciones y Terminación',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center
                      ),
                      SizedBox(height: 8),

                      Text(
                        'La Empresa se reserva el derecho de modificar este '
                        'Acuerdo en cualquier momento. Las modificaciones '
                        'serán notificadas dentro de la aplicación. '
                        'Asimismo, podrá suspender o cancelar el acceso del '
                        'Usuario ante cualquier incumplimiento. '
                        'El Usuario también podrá cancelar su cuenta en '
                        'cualquier momento desde la configuración de perfil.',
                        textAlign: TextAlign.justify
                      ),
                      SizedBox(height: 16),

                      Text(
                        'Limitación de Responsabilidad',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center
                      ),
                      SizedBox(height: 8),

                      Text(
                        'La Empresa no será responsable por daños directos, '
                        'indirectos, incidentales o consecuentes derivados '
                        'del uso o la imposibilidad de uso de la plataforma. '
                        'El Usuario acepta utilizar el servicio '
                        'bajo su propio riesgo.',
                        textAlign: TextAlign.justify
                      ),
                      SizedBox(height: 16)
                    ]
                )
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar')
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) =>
                      const Unauthorized())
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Rechazar')
                )
              ]
            )
          )
        ]
      )
    );
  }
}