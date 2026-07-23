package com.nexuswavetech.geetanexus.data

import com.nexuswavetech.geetanexus.domain.models.ScriptureSection
import com.nexuswavetech.geetanexus.domain.models.ScriptureType

/**
 * Bundled metadata for Shiva Mahapurana and Ramcharitmanas.
 * Bhagavad Gita verses are fetched live from DharmicData GitHub.
 */
object ScriptureData {

    val shivaMahapuranaSamhitas: List<ScriptureSection> = listOf(
        ScriptureSection(
            id = "shiva_1", scripture = ScriptureType.SHIVA_MAHAPURANA,
            number = 1, title = "Vidyeshvara Samhita", subtitle = "The Knowledge of the Lord",
            description = "This opening Samhita establishes the glory of Lord Shiva, describes the significance of Shiva Purana and the worship of Shivalinga. It contains teachings on dharma, devotion and the path to liberation through Shiva's grace.",
            verseCount = 10000
        ),
        ScriptureSection(
            id = "shiva_2", scripture = ScriptureType.SHIVA_MAHAPURANA,
            number = 2, title = "Rudra Samhita", subtitle = "The Story of Rudra",
            description = "The largest Samhita, divided into five khandas: Srishti (Creation), Sati, Parvati, Kumar and Yuddha. It narrates the marriage of Shiva-Parvati, birth of Kartikeya and Ganesha, and the defeat of Tarakasura.",
            verseCount = 8000
        ),
        ScriptureSection(
            id = "shiva_3", scripture = ScriptureType.SHIVA_MAHAPURANA,
            number = 3, title = "Shatrudra Samhita", subtitle = "The Hundred Rudras",
            description = "Describes the various forms and manifestations of Rudra, the fierce aspect of Shiva. Narrates stories of devotees, the significance of various sacred places (tirthas) associated with Shiva.",
            verseCount = 3000
        ),
        ScriptureSection(
            id = "shiva_4", scripture = ScriptureType.SHIVA_MAHAPURANA,
            number = 4, title = "Koti Rudra Samhita", subtitle = "Ten Million Rudras",
            description = "Contains the twelve Jyotirlingas — the most sacred shrines of Shiva — along with their origin stories, significance, and the fruits of visiting each. An essential pilgrimage guide.",
            verseCount = 4000
        ),
        ScriptureSection(
            id = "shiva_5", scripture = ScriptureType.SHIVA_MAHAPURANA,
            number = 5, title = "Uma Samhita", subtitle = "The Story of Uma",
            description = "Narrates the story of Goddess Uma (Parvati) — her birth, austerities, marriage to Shiva, and her role as the Divine Mother. Describes the nature of the soul and paths to moksha.",
            verseCount = 4000
        ),
        ScriptureSection(
            id = "shiva_6", scripture = ScriptureType.SHIVA_MAHAPURANA,
            number = 6, title = "Kailasa Samhita", subtitle = "Wisdom from Kailasa",
            description = "A philosophical discourse from Mount Kailasa — Shiva's abode. Contains teachings on Yoga, Vedanta, and the nature of Brahman. Nandikesvara explains to sages the ultimate truth.",
            verseCount = 2000
        ),
        ScriptureSection(
            id = "shiva_7", scripture = ScriptureType.SHIVA_MAHAPURANA,
            number = 7, title = "Vayaviya Samhita", subtitle = "The Words of Vayu",
            description = "Narrated by the Wind God Vayu. Contains the most profound philosophical teachings of the Purana, including the Shaiva Siddhanta, metaphysics of liberation, and esoteric knowledge.",
            verseCount = 4000
        )
    )

    val ramcharitmanas: List<ScriptureSection> = listOf(
        ScriptureSection(
            id = "ram_1", scripture = ScriptureType.RAMCHARITMANAS,
            number = 1, title = "Bal Kanda", subtitle = "The Book of Childhood",
            description = "Describes the birth and early life of Shri Ram in Ayodhya, his education under Vishwamitra, the liberation of Ahalya, Ram's participation in Sita's Swayamvar and the breaking of Shiva's bow.",
            verseCount = 361
        ),
        ScriptureSection(
            id = "ram_2", scripture = ScriptureType.RAMCHARITMANAS,
            number = 2, title = "Ayodhya Kanda", subtitle = "The Book of Ayodhya",
            description = "Covers Ram's planned coronation, Kaikeyi's boons, Ram's exile to the forest for 14 years with Sita and Lakshman, King Dasharatha's death of grief, and Bharat's meeting with Ram at Chitrakoot.",
            verseCount = 326
        ),
        ScriptureSection(
            id = "ram_3", scripture = ScriptureType.RAMCHARITMANAS,
            number = 3, title = "Aranya Kanda", subtitle = "The Book of the Forest",
            description = "Ram's life in the Dandaka forest, encounters with sages and demons, Surpanakha's disfigurement, the golden deer deception, Sita's abduction by Ravana, and Jatayu's heroic sacrifice.",
            verseCount = 46
        ),
        ScriptureSection(
            id = "ram_4", scripture = ScriptureType.RAMCHARITMANAS,
            number = 4, title = "Kishkindha Kanda", subtitle = "The Book of Kishkindha",
            description = "Ram meets Hanuman and Sugriva, slays Bali, and the search for Sita begins. Hanuman is identified as the ideal devotee and is sent on the mission to Lanka.",
            verseCount = 30
        ),
        ScriptureSection(
            id = "ram_5", scripture = ScriptureType.RAMCHARITMANAS,
            number = 5, title = "Sundar Kanda", subtitle = "The Beautiful Book",
            description = "The most beloved kanda — Hanuman's flight to Lanka, his search for Sita in Ashok Vatika, his meeting with Sita, the burning of Lanka, and his return with news of Sita. A complete text of hope and devotion.",
            verseCount = 60
        ),
        ScriptureSection(
            id = "ram_6", scripture = ScriptureType.RAMCHARITMANAS,
            number = 6, title = "Lanka Kanda", subtitle = "The Book of Lanka",
            description = "The great war between Ram's army of Vanaras and Ravana's Lanka. Includes construction of Ram Setu, battles with demon generals, Lakshman's revival by Sanjivani, and the final defeat of Ravana.",
            verseCount = 117
        ),
        ScriptureSection(
            id = "ram_7", scripture = ScriptureType.RAMCHARITMANAS,
            number = 7, title = "Uttar Kanda", subtitle = "The Final Book",
            description = "Ram's return to Ayodhya, Ram Rajya, philosophical discourses between Kak Bhushundi and Garuda, and Shiva explaining the glory of Ram Katha to Parvati. The eternal message of Ram's divine rule.",
            verseCount = 130
        )
    )

    fun sectionsFor(type: ScriptureType): List<ScriptureSection> = when (type) {
        ScriptureType.SHIVA_MAHAPURANA -> shivaMahapuranaSamhitas
        ScriptureType.RAMCHARITMANAS  -> ramcharitmanas
        ScriptureType.BHAGAVAD_GITA   -> emptyList() // fetched from DharmicData
    }
}
