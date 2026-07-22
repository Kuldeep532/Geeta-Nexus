package com.nexuswavetech.geetanexus.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.nexuswavetech.geetanexus.ui.screens.*

sealed class Screen(val route: String) {
    data object Home        : Screen("home")
    data object Chapters    : Screen("chapters")
    data object AiChat      : Screen("ai_chat")
    data object Bookmarks   : Screen("bookmarks")
    data object Search      : Screen("search")
    data object Profile     : Screen("profile")
    data object Onboarding  : Screen("onboarding")
    data object More        : Screen("more")

    data object ChapterDetail : Screen("chapter/{chapterNumber}") {
        fun route(chapterNumber: Int) = "chapter/$chapterNumber"
    }
    data object VerseReader : Screen("verse/{chapterNumber}/{verseNumber}") {
        fun route(chapter: Int, verse: Int) = "verse/$chapter/$verse"
    }
}

@Composable
fun GeetaNexusNavGraph(
    navController: NavHostController,
    startDestination: String = Screen.Home.route
) {
    NavHost(navController = navController, startDestination = startDestination) {

        composable(Screen.Home.route) {
            HomeScreen(navController = navController)
        }

        composable(Screen.Chapters.route) {
            ChaptersScreen(navController = navController)
        }

        composable(
            route = Screen.ChapterDetail.route,
            arguments = listOf(navArgument("chapterNumber") { type = NavType.IntType })
        ) { back ->
            val chapter = back.arguments?.getInt("chapterNumber") ?: 1
            ChapterDetailScreen(chapterNumber = chapter, navController = navController)
        }

        composable(
            route = Screen.VerseReader.route,
            arguments = listOf(
                navArgument("chapterNumber") { type = NavType.IntType },
                navArgument("verseNumber")   { type = NavType.IntType }
            )
        ) { back ->
            val chapter = back.arguments?.getInt("chapterNumber") ?: 1
            val verse   = back.arguments?.getInt("verseNumber") ?: 1
            VerseReaderScreen(chapterNumber = chapter, verseNumber = verse, navController = navController)
        }

        composable(Screen.AiChat.route)   { AiChatScreen(navController = navController) }
        composable(Screen.Bookmarks.route) { BookmarksScreen(navController = navController) }
        composable(Screen.Search.route)    { SearchScreen(navController = navController) }
        composable(Screen.Profile.route)   { ProfileScreen(navController = navController) }
        composable(Screen.More.route)      { MoreScreen(navController = navController) }
        composable(Screen.Onboarding.route) { OnboardingScreen(navController = navController) }
    }
}
