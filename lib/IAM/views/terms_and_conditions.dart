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
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),

                    Text(
                      'Al acceder, descargar o utilizar la aplicación móvil '
                      'HelpTech, usted declara que ha leído, comprendido y '
                      'aceptado íntegramente los presentes Términos y '
                      'Condiciones de Uso. El uso de la Aplicación constituye '
                      'un acuerdo legalmente vinculante entre el usuario y'
                      'la empresa Technology Advances Services titular y '
                      'operadora de la misma. En caso de no estar de acuerdo '
                      'con alguna de las disposiciones establecidas, le '
                      'solicitamos abstenerse de utilizar la Aplicación.',
                      textAlign: TextAlign.justify
                    ),
                    SizedBox(height: 16),

                    Text(
                      'La Aplicación tiene por objetivo facilitar la '
                      'solicitud y oferta de servicios técnicos especializados, '
                      'optimizando el tiempo destinado por los usuarios a la '
                      'búsqueda de profesionales para resolver problemas '
                      'técnicos de índole doméstica. Asimismo, la Aplicación '
                      'promueve oportunidades laborales para especialistas '
                      'mediante la publicación de sus servicios.',
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 16),

                    Text(
                      'El acceso a ciertas funcionalidades de la Aplicación '
                      'requiere el registro del Usuario mediante la '
                      'provisión de información personal veraz y '
                      'actualizada, incluyendo dni, nombre completo, correo '
                      'electrónico y número de teléfono móvil. '
                      'Al registrarse, el Usuario autoriza el uso de dicha '
                      'información exclusivamente para fines operativos '
                      'relacionados con la prestación de los servicios, y se '
                      'compromete a mantener la confidencialidad de sus '
                      'credenciales de acceso.',
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 16),

                    Text(
                      'La Empresa se compromete a garantizar la privacidad y '
                      'protección de los datos personales suministrados por '
                      'los Usuarios. La información recopilada será tratada '
                      'con estricta confidencialidad y resguardada mediante '
                      'mecanismos de seguridad adecuados, incluyendo la '
                      'implementación de tokens de autenticación en el '
                      'backend para prevenir accesos no autorizados.',
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 16),

                    Text(
                      'El uso completo de la Aplicación está condicionado a la '
                      'adquisición de planes de suscripción, cuyo pago se '
                      'realizará exclusivamente mediante tarjeta de crédito '
                      'o débito. Los precios, características y duraciones '
                      'de los planes estarán claramente especificados '
                      'dentro de la Aplicación.',
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 16),

                    Text(
                      'Todos los derechos de propiedad intelectual '
                      'relacionados con la Aplicación, incluyendo su diseño, '
                      'funcionalidades y contenido, son de exclusiva '
                      'propiedad de Technology Advances Services.',
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 16),

                    Text(
                      'Para cualquier consulta, queja o solicitud relacionada '
                      'con estos términos y condiciones, los usuarios pueden '
                      'contactarnos mediante el correo electrónico '
                      'technologyadvancesservices@gmail.com.',
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 16),

                    Text(
                      'Derechos de Autor y Propiedad Intelectual',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),

                    Text(
                      'Esta aplicación y la idea original del proyecto son '
                      'propiedad del INGENIERO AARON ELIAS ACUÑA ALARCON, '
                      'el cual es el único titular legal de todos los '
                      'derechos de autor, propiedad intelectual y '
                      'responsabilidad comercial vinculados a la presente '
                      'plataforma. Cualquier uso no autorizado de su '
                      'contenido, diseño o funcionalidades será considerado '
                      'una violación a la ley de propiedad intelectual.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red
                      ),
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