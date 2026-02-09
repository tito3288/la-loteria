//
//  LoteriaCard.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/14/26.
//

import Foundation

struct LoteriaCard: Identifiable, Hashable {
    let id: Int
    let name: String
    let riddle: String
    let imageName: String
    
    init(id: Int, name: String, riddle: String, imageName: String = "") {
        self.id = id
        self.name = name
        self.riddle = riddle
        self.imageName = imageName.isEmpty ? "card_\(id)" : imageName
    }
}

// MARK: - All 54 Traditional Lotería Cards
extension LoteriaCard {
    static let allCards: [LoteriaCard] = [
        LoteriaCard(id: 1, name: "El Gallo", riddle: "El que le cantó a San Pedro"),
        LoteriaCard(id: 2, name: "El Diablito", riddle: "Portate bien, cuatito"),
        LoteriaCard(id: 3, name: "La Dama", riddle: "Puliendo el paso por toda la calle"),
        LoteriaCard(id: 4, name: "El Catrín", riddle: "Don Ferruco en la alameda"),
        LoteriaCard(id: 5, name: "El Paraguas", riddle: "Para el sol y la lluvia"),
        LoteriaCard(id: 6, name: "La Sirena", riddle: "Con los encantos del mar"),
        LoteriaCard(id: 7, name: "La Escalera", riddle: "Las mujeres suben, los hombres bajan"),
        LoteriaCard(id: 8, name: "La Botella", riddle: "La que no debe caer"),
        LoteriaCard(id: 9, name: "El Barril", riddle: "Tanto bebió el cantinero"),
        LoteriaCard(id: 10, name: "El Árbol", riddle: "El que a tu abuelo dio sombra"),
        LoteriaCard(id: 11, name: "El Melón", riddle: "Me lo das o me lo quitas"),
        LoteriaCard(id: 12, name: "El Valiente", riddle: "Porque al cobarde no se le hace"),
        LoteriaCard(id: 13, name: "El Gorrito", riddle: "Ponmelo y te lo quito"),
        LoteriaCard(id: 14, name: "La Muerte", riddle: "La que a todos se los lleva"),
        LoteriaCard(id: 15, name: "La Pera", riddle: "El que espera desespera"),
        LoteriaCard(id: 16, name: "La Bandera", riddle: "Verde, blanco y colorado"),
        LoteriaCard(id: 17, name: "El Bandolón", riddle: "Tocando su bandolón"),
        LoteriaCard(id: 18, name: "El Violoncello", riddle: "Creciendo se fue hasta el cielo"),
        LoteriaCard(id: 19, name: "La Garza", riddle: "Al otro lado del río"),
        LoteriaCard(id: 20, name: "El Pájaro", riddle: "Tu que vuelas como él"),
        LoteriaCard(id: 21, name: "La Mano", riddle: "La del metate"),
        LoteriaCard(id: 22, name: "La Bota", riddle: "Una es de ida y otra de venida"),
        LoteriaCard(id: 23, name: "La Luna", riddle: "El farol de los enamorados"),
        LoteriaCard(id: 24, name: "El Cotorro", riddle: "Ave de mal agüero"),
        LoteriaCard(id: 25, name: "El Borracho", riddle: "A ver si como no puede dejar de tomar"),
        LoteriaCard(id: 26, name: "El Negrito", riddle: "El que se comió el azúcar"),
        LoteriaCard(id: 27, name: "El Corazón", riddle: "No me extrañes corazón"),
        LoteriaCard(id: 28, name: "La Sandía", riddle: "La barriga que Juan tenía"),
        LoteriaCard(id: 29, name: "El Tambor", riddle: "No te arrugues, cuero viejo"),
        LoteriaCard(id: 30, name: "El Camarón", riddle: "Camarón que se duerme"),
        LoteriaCard(id: 31, name: "Las Jaras", riddle: "Las que florecen en mayo"),
        LoteriaCard(id: 32, name: "El Músico", riddle: "El que vive de serenata"),
        LoteriaCard(id: 33, name: "La Araña", riddle: "Atarántamela a palos"),
        LoteriaCard(id: 34, name: "El Soldado", riddle: "Uno, dos y tres"),
        LoteriaCard(id: 35, name: "La Estrella", riddle: "La guía de los marineros"),
        LoteriaCard(id: 36, name: "El Cazo", riddle: "El que sirve la olla"),
        LoteriaCard(id: 37, name: "El Mundo", riddle: "Este mundo es una bola"),
        LoteriaCard(id: 38, name: "El Apache", riddle: "¡Ah Chihuahua, cuánto apache!"),
        LoteriaCard(id: 39, name: "El Nopal", riddle: "Metate de mexicanos"),
        LoteriaCard(id: 40, name: "El Alacrán", riddle: "El que pica a los malvados"),
        LoteriaCard(id: 41, name: "La Rosa", riddle: "Rosita, Rosaura, del jardín eres señora"),
        LoteriaCard(id: 42, name: "La Calavera", riddle: "Al pasar por el panteón"),
        LoteriaCard(id: 43, name: "La Campana", riddle: "Tú con la campana y yo con el badajo"),
        LoteriaCard(id: 44, name: "El Cantarito", riddle: "Tanto va el cántaro al agua"),
        LoteriaCard(id: 45, name: "El Venado", riddle: "Saltando va buscando"),
        LoteriaCard(id: 46, name: "El Sol", riddle: "La cobija de los pobres"),
        LoteriaCard(id: 47, name: "La Corona", riddle: "Las espinas de una flor"),
        LoteriaCard(id: 48, name: "La Chalupa", riddle: "Rema que rema Lupita"),
        LoteriaCard(id: 49, name: "El Pino", riddle: "Fresco y oloroso"),
        LoteriaCard(id: 50, name: "El Pescado", riddle: "El que por la boca muere"),
        LoteriaCard(id: 51, name: "La Palma", riddle: "Palmero, súbete a la palma"),
        LoteriaCard(id: 52, name: "La Maceta", riddle: "El que nace pa' tamal"),
        LoteriaCard(id: 53, name: "El Arpa", riddle: "Arpa vieja de mi suegra"),
        LoteriaCard(id: 54, name: "La Rana", riddle: "Al ver que no puedes, saltas")
    ]
}
