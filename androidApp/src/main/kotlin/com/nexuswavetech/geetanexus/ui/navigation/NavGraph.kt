package com.nexuswavetech.geetanexus.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.nexuswavetech.geetanexus.ui.screens.*
import com.nexuswavetech.geetanexus.ui.viewmodel.AudioViewModel
import org.koin.androidx.compose.koinViewModel

sealed class Screen(val route: String) {
    object Home           : Screen("home")
    object Scriptures     : Screen("scriptures")
    object Chapters       : Screen("chapters")
    object AiChat         : Screen("ai_chat")
    object Bookmarks      : Screen("bookmarks")
    object Quiz           : Screen("quiz")
    object Notes          : Screen("notes")
    object ReadingPlan    : Screen("reading_plan")
    object Profile        : Screen("profile")
    object Auth           : Screen("auth")
    object Search         : Screen("search")
    object Onboarding     : Screen("onboarding")
    object More           : Screen("more")
    object About          : Screen("about")
    object Privacy        : Screen("privacy_policy")
    object Terms          : Screen("terms")

    object ChapterDetail : Screen("chapter_detail/{chapterNumber}") {
        fun route(n: Int) = "chapter_detail/$n"
    }
    object VerseReader : Screen("verse_reader/{chapterNumber}/{verseNumber}") {
        fun route(ch: Int, v: Int) = "verse_reader/$ch/$v"
    }
    object ScriptureDetail : Screen("scripture_detail/{scriptureType}") {
        fun route(type: String) = "scripture_detail/$type"
    }
    object ScriptureSectionDetail : Screen("scripture_section/{scriptureType}/{sectionId}") {
        fun route(type: String, sectionId: String) = "scripture_section/$type/$sectionId"
    }
}

/** Routes where the bottom nav bar is hidden. */
val fullScreenRoutes = setOf(
    Screen.Onboarding.route,
    Screen.Auth.route,
    "verse_reader/",
    "scripture_section/"
)

@Composable
fun GeetaNexusNavGraph(
    navController: NavHostController,
    audioViewModel: AudioViewModel,
    modifier: Modifier = Modifier,
    startDestination: String = Screen.Home.route
) {
    NavHost(
        navController    = navController,
        startDestination = startDestination,
        modifier         = modifier
    ) {
        composable(Screen.Home.route) {
            HomeScreen(navController = navController)
        }

        composable(Screen.Scriptures.route) {
            ScripturesScreen(navController = navController)
        }

        composable(Screen.Chapters.route) {
            ChaptersScreen(navController = navController)
        }

        composable(
            route = Screen.ChapterDetail.route,
            arguments = listOf(navArgument("chapterNumber") { type = NavType.IntType })
        ) { back ->
            ChapterDetailScreen(
                chapterNumber = back.arguments?.getInt("chapterNumber") ?: 1,
                navController = navController
            )
        }

        composable(
            route = Screen.VerseReader.route,
            arguments = listOf(
                navArgument("chapterNumber") { type = NavType.IntType },
                navArgument("verseNumber")   { type = NavType.IntType }
            )
        ) { back ->
            VerseReaderScreen(
                chapterNumber  = back.arguments?.getInt("chapterNumber") ?: 1,
                verseNumber    = back.arguments?.getInt("verseNumber")   ?: 1,
                navController  = navController,
                audioViewModel = audioViewModel
            )
        }

        composable(
            route = Screen.ScriptureDetail.route,
            arguments = listOf(navArgument("scriptureType") { type = NavType.StringType })
        ) { back ->
            ScriptureDetailScreen(
                scriptureType = back.arguments?.getString("scriptureType") ?: "SHIVA_MAHAPURANA",
                navController = navController
            )
        }

        composable(
            route = Screen.ScriptureSectionDetail.route,
            arguments = listOf(
                navArgument("scriptureType") { type = NavType.StringType },
                navArgument("sectionId")     { type = NavType.StringType }
            )
        ) { back ->
            ScriptureSectionScreen(
                scriptureType  = back.arguments?.getString("scriptureType") ?: "",
                sectionId      = back.arguments?.getString("sectionId")     ?: "",
                navController  = navController,
                audioViewModel = audioViewModel
            )
        }

        composable(Screen.AiChat.route)     { AiChatScreen(navController = navController) }
        composable(Screen.Bookmarks.route)  { BookmarksScreen(navController = navController) }
        composable(Screen.Quiz.route)       { QuizScreen(navController = navController) }
        composable(Screen.Notes.route)      { NotesScreen(navController = navController) }
        composable(Screen.ReadingPlan.route){ ReadingPlanScreen(navController = navController) }
        composable(Screen.Search.route)     { SearchScreen(navController = navController) }
        composable(Screen.Profile.route)    { ProfileScreen(navController = navController) }
        composable(Screen.More.route)       { MoreScreen(navController = navController) }
        composable(Screen.About.route)      { AboutScreen(navController = navController) }
        composable(Screen.Privacy.route)    { PrivacyPolicyScreen(navController = navController) }
        composable(Screen.Terms.route)      { TermsScreen(navController = navController) }
        composable(Screen.Onboarding.route) { OnboardingScreen(navController = navController) }
        composable(Screen.Auth.route) {
            AuthScreen(
                navController = navController,
                onAuthSuccess = { navController.popBackStack() }
            )
        }
    }
}
