import Foundation

struct Dua {
    let title: String
    let arabic: String
    let transliteration: String
    let translation: String
}

extension Dua {
    static let all: [Dua] = [
        Dua(
            title: "HR. Bukhari",
            arabic: "اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ",
            transliteration: "Allāhumma Rabba hāżihid da'watit tāmmah, waṣ-ṣalātil qā'imah, āti Muḥammadanil wasīlata wal faḍīlah, wab'aṡhu maqāman maḥmūdanil lażī wa'adtah.",
            translation: "Ya Allah, Tuhan pemilik seruan yang sempurna ini dan sholat yang akan ditegakkan, karuniakanlah kepada Muhammad wasilah dan keutamaan, dan bangkitkanlah beliau ke tempat terpuji yang telah Engkau janjikan."
        ),
        Dua(
            title: "HR. Abu Dawud, Tirmidzi",
            arabic: "الدُّعَاءُ لَا يُرَدُّ بَيْنَ الْأَذَانِ وَالْإِقَامَةِ",
            transliteration: "Ad-du'ā'u lā yuraddu bainal ażāni wal iqāmah.",
            translation: "Doa tidak akan ditolak antara adzan dan iqamah. Berdoalah dengan sungguh-sungguh di waktu ini."
        ),
        Dua(
            title: "QS. Al-Baqarah: 201",
            arabic: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
            transliteration: "Rabbanā ātinā fid dunyā ḥasanah, wa fil ākhirati ḥasanah, wa qinā 'ażāban nār.",
            translation: "Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat, dan lindungilah kami dari azab neraka."
        ),
        Dua(
            title: "HR. Ibnu Majah",
            arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا",
            transliteration: "Allāhumma innī as'aluka 'ilman nāfi'ā, wa rizqan ṭayyibā, wa 'amalan mutaqabbalā.",
            translation: "Ya Allah, aku memohon kepada-Mu ilmu yang bermanfaat, rezeki yang baik, dan amal yang diterima."
        ),
        Dua(
            title: "Sayyidul Istighfar — HR. Bukhari",
            arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
            transliteration: "Allāhumma Anta Rabbī lā ilāha illā Anta, khalaqtanī wa ana 'abduka, wa ana 'alā 'ahdika wa wa'dika mastaṭa'tu, a'ūżu bika min syarri mā ṣana'tu, abū'u laka bini'matika 'alayya wa abū'u biżanbī, faghfir lī fa innahu lā yaghfiruż żunūba illā Anta.",
            translation: "Ya Allah, Engkau Tuhanku, tidak ada tuhan selain Engkau. Engkau menciptakanku dan aku hamba-Mu. Aku berada di atas perjanjian dan janji-Mu semampuku. Aku berlindung kepada-Mu dari keburukan yang kuperbuat. Aku mengakui nikmat-Mu kepadaku dan mengakui dosaku, maka ampunilah aku, sesungguhnya tidak ada yang mengampuni dosa selain Engkau."
        ),
        Dua(
            title: "HR. Muslim",
            arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ وَمِنْ عَذَابِ جَهَنَّمَ وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ",
            transliteration: "Allāhumma innī a'ūżu bika min 'ażābil qabr, wa min 'ażābi jahannam, wa min fitnatil maḥyā wal mamāt, wa min syarri fitnatil masīḥid dajjāl.",
            translation: "Ya Allah, aku berlindung kepada-Mu dari siksa kubur, dari siksa neraka Jahannam, dari fitnah kehidupan dan kematian, dan dari kejahatan fitnah Dajjal."
        ),
    ]
}
