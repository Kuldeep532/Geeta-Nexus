package com.nexuswavetech.geetanexus.data

import com.nexuswavetech.geetanexus.domain.models.QuizCategory
import com.nexuswavetech.geetanexus.domain.models.QuizQuestion
import com.nexuswavetech.geetanexus.domain.repository.QuizRepository

class QuizRepositoryImpl : QuizRepository {

    override suspend fun getQuestions(
        category: QuizCategory?,
        limit: Int
    ): Result<List<QuizQuestion>> = runCatching {
        val pool = if (category == null) ALL_QUESTIONS
                   else ALL_QUESTIONS.filter { it.category == category }
        pool.shuffled().take(limit)
    }

    override suspend fun getAllCategories(): List<QuizCategory> = QuizCategory.entries

    companion object {
        private val ALL_QUESTIONS = listOf(
            // ── Bhagavad Gita — General ──────────────────────────────────────
            QuizQuestion(
                id = "bg_1", category = QuizCategory.GENERAL,
                question = "Bhagavad Gita किस महाग्रंथ का हिस्सा है?",
                options = listOf("रामायण", "महाभारत", "पुराण", "उपनिषद"),
                correctIndex = 1,
                explanation = "भगवद गीता महाभारत के भीष्म पर्व (अध्याय 23–40) का हिस्सा है।",
                verseRef = null
            ),
            QuizQuestion(
                id = "bg_2", category = QuizCategory.GENERAL,
                question = "Bhagavad Gita में कुल कितने अध्याय हैं?",
                options = listOf("12", "14", "18", "21"),
                correctIndex = 2,
                explanation = "भगवद गीता में 18 अध्याय और 700 श्लोक हैं।",
                verseRef = null
            ),
            QuizQuestion(
                id = "bg_3", category = QuizCategory.GENERAL,
                question = "Bhagavad Gita का उपदेश किसने दिया था?",
                options = listOf("भीष्म", "व्यास", "श्रीकृष्ण", "नारद"),
                correctIndex = 2,
                explanation = "श्रीकृष्ण ने कुरुक्षेत्र के युद्ध में अर्जुन को गीता का उपदेश दिया।",
                verseRef = null
            ),
            QuizQuestion(
                id = "bg_4", category = QuizCategory.KARMA,
                question = "BG 2.47 — 'कर्मण्येवाधिकारस्ते...' इस श्लोक का मुख्य संदेश क्या है?",
                options = listOf(
                    "फल की इच्छा रखो",
                    "केवल कर्म करो, फल की चिंता न करो",
                    "युद्ध से भागो",
                    "ध्यान करो"
                ),
                correctIndex = 1,
                explanation = "श्रीकृष्ण कहते हैं: तुम्हारा अधिकार केवल कर्म करने में है, उसके फलों में नहीं।",
                verseRef = "BG 2.47"
            ),
            QuizQuestion(
                id = "bg_5", category = QuizCategory.DHARMA,
                question = "गीता के अनुसार, स्वधर्म क्या है?",
                options = listOf(
                    "धर्म बदलना",
                    "दूसरे का धर्म अपनाना",
                    "अपने कर्तव्य का पालन करना",
                    "संन्यास लेना"
                ),
                correctIndex = 2,
                explanation = "BG 3.35: अपना धर्म अपूर्ण रूप से पालन करना, दूसरे के धर्म के सुचारु पालन से श्रेष्ठ है।",
                verseRef = "BG 3.35"
            ),
            QuizQuestion(
                id = "bg_6", category = QuizCategory.JNANA,
                question = "गीता में आत्मा के बारे में क्या कहा गया है?",
                options = listOf(
                    "आत्मा नश्वर है",
                    "आत्मा को शस्त्र काट सकते हैं",
                    "आत्मा अजर-अमर और अविनाशी है",
                    "आत्मा शरीर के साथ मरती है"
                ),
                correctIndex = 2,
                explanation = "BG 2.20: न यह जन्म लेती है, न मरती है, न कभी हुई है, न होगी — यह शाश्वत, पुरातन है।",
                verseRef = "BG 2.20"
            ),
            QuizQuestion(
                id = "bg_7", category = QuizCategory.BHAKTI,
                question = "BG 18.66 में श्रीकृष्ण क्या कहते हैं?",
                options = listOf(
                    "ज्ञान प्राप्त करो",
                    "युद्ध करो",
                    "सब धर्म छोड़ मुझमें शरण लो, मैं मुक्त करूँगा",
                    "तपस्या करो"
                ),
                correctIndex = 2,
                explanation = "यह गीता का चरम संदेश है — 'मामेकं शरणं व्रज।'",
                verseRef = "BG 18.66"
            ),
            QuizQuestion(
                id = "bg_8", category = QuizCategory.KARMA,
                question = "निष्काम कर्म का अर्थ क्या है?",
                options = listOf(
                    "कर्म न करना",
                    "फल की इच्छा रखते हुए कर्म करना",
                    "फल की इच्छा किए बिना कर्म करना",
                    "दूसरों के लिए कर्म करना"
                ),
                correctIndex = 2,
                explanation = "निष्काम कर्म — फल से अनासक्त होकर केवल कर्तव्य के रूप में कर्म — गीता का मूल सिद्धांत है।",
                verseRef = "BG 2.47"
            ),
            QuizQuestion(
                id = "bg_9", category = QuizCategory.GENERAL,
                question = "गीता में 'गुण' कितने प्रकार के हैं?",
                options = listOf("दो", "तीन", "चार", "पाँच"),
                correctIndex = 1,
                explanation = "सत्व, रज और तम — ये तीन गुण प्रकृति का आधार हैं (BG 14.5)।",
                verseRef = "BG 14.5"
            ),
            QuizQuestion(
                id = "bg_10", category = QuizCategory.JNANA,
                question = "BG 4.7 में श्रीकृष्ण कहते हैं वे धरती पर क्यों आते हैं?",
                options = listOf(
                    "खेलने के लिए",
                    "धर्म की रक्षा और अधर्म के नाश के लिए",
                    "राज्य करने के लिए",
                    "ज्ञान देने के लिए"
                ),
                correctIndex = 1,
                explanation = "'परित्राणाय साधूनाम् विनाशाय च दुष्कृताम्' — धर्म की स्थापना के लिए।",
                verseRef = "BG 4.7-8"
            ),

            // ── Shiva Mahapurana ─────────────────────────────────────────────
            QuizQuestion(
                id = "shiva_1", category = QuizCategory.SHIVA,
                question = "शिव महापुराण में कितनी संहिताएँ हैं?",
                options = listOf("5", "6", "7", "8"),
                correctIndex = 2,
                explanation = "शिव महापुराण में 7 संहिताएँ हैं — विद्येश्वर, रुद्र, शतरुद्र, कोटिरुद्र, उमा, कैलाश और वायवीय।",
                verseRef = null
            ),
            QuizQuestion(
                id = "shiva_2", category = QuizCategory.SHIVA,
                question = "ओम नमः शिवाय — इस पंचाक्षरी मंत्र में कितने अक्षर हैं?",
                options = listOf("3", "4", "5", "6"),
                correctIndex = 2,
                explanation = "'न-मः-शि-वा-य' — ये पाँच अक्षर पंचभूतों का प्रतीक हैं।",
                verseRef = null
            ),
            QuizQuestion(
                id = "shiva_3", category = QuizCategory.SHIVA,
                question = "महाशिवरात्रि का पर्व किस माह में मनाया जाता है?",
                options = listOf("कार्तिक", "माघ/फाल्गुन", "चैत्र", "आषाढ़"),
                correctIndex = 1,
                explanation = "महाशिवरात्रि फाल्गुन मास के कृष्ण पक्ष की चतुर्दशी को मनाई जाती है।",
                verseRef = null
            ),

            // ── Ramcharitmanas ───────────────────────────────────────────────
            QuizQuestion(
                id = "ram_1", category = QuizCategory.RAMCHARITMANAS,
                question = "रामचरितमानस की रचना किसने की?",
                options = listOf("वाल्मीकि", "तुलसीदास", "कबीर", "सूरदास"),
                correctIndex = 1,
                explanation = "गोस्वामी तुलसीदास ने 16वीं शताब्दी में अवधी भाषा में रामचरितमानस की रचना की।",
                verseRef = null
            ),
            QuizQuestion(
                id = "ram_2", category = QuizCategory.RAMCHARITMANAS,
                question = "रामचरितमानस में कितने काण्ड हैं?",
                options = listOf("5", "6", "7", "8"),
                correctIndex = 2,
                explanation = "बाल, अयोध्या, अरण्य, किष्किंधा, सुंदर, लंका और उत्तर — सात काण्ड।",
                verseRef = null
            ),
            QuizQuestion(
                id = "ram_3", category = QuizCategory.RAMCHARITMANAS,
                question = "तुलसीदास ने 'राम नाम मणि दीप धरु...' में किसे दीपक कहा?",
                options = listOf("हनुमान", "राम का नाम", "सीता", "जनक"),
                correctIndex = 1,
                explanation = "तुलसीदास कहते हैं: राम का नाम एक मणिदीप है — इसे जीभ की देहरी पर रखो।",
                verseRef = null
            ),
            QuizQuestion(
                id = "ram_4", category = QuizCategory.RAMCHARITMANAS,
                question = "भगवान राम का वनवास कितने वर्षों का था?",
                options = listOf("12 वर्ष", "14 वर्ष", "18 वर्ष", "7 वर्ष"),
                correctIndex = 1,
                explanation = "कैकेयी के वरदान के कारण राम को 14 वर्ष का वनवास मिला।",
                verseRef = null
            )
        )
    }
}
