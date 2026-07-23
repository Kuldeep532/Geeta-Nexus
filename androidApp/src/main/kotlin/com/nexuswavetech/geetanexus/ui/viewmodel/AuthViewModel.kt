package com.nexuswavetech.geetanexus.ui.viewmodel

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexuswavetech.geetanexus.data.FirebaseUserRepository
import com.nexuswavetech.geetanexus.domain.models.UserProfile
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

sealed class AuthState {
    object Idle        : AuthState()
    object Loading     : AuthState()
    data class Success(val user: UserProfile) : AuthState()
    data class Error(val message: String)     : AuthState()
}

class AuthViewModel(
    private val userRepo: FirebaseUserRepository
) : ViewModel() {

    private val _authState = MutableStateFlow<AuthState>(AuthState.Idle)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    fun signInWithGoogle(activityContext: Context) {
        viewModelScope.launch {
            _authState.value = AuthState.Loading
            userRepo.signInWithGoogle(activityContext)
                .onSuccess { _authState.value = AuthState.Success(it) }
                .onFailure { e ->
                    _authState.value = AuthState.Error(
                        when {
                            e.message?.contains("cancel", true) == true -> "Sign-in cancelled."
                            e.message?.contains("network", true) == true -> "No internet connection."
                            else -> "Sign-in failed. Please try again."
                        }
                    )
                }
        }
    }

    fun signInWithEmail(email: String, password: String) {
        if (email.isBlank() || password.isBlank()) {
            _authState.value = AuthState.Error("Email and password cannot be empty.")
            return
        }
        viewModelScope.launch {
            _authState.value = AuthState.Loading
            userRepo.signInWithEmailPassword(email, password)
                .onSuccess { _authState.value = AuthState.Success(it) }
                .onFailure { _authState.value = AuthState.Error("Incorrect email or password.") }
        }
    }

    fun signUpWithEmail(email: String, password: String, name: String) {
        if (email.isBlank() || password.isBlank() || name.isBlank()) {
            _authState.value = AuthState.Error("All fields are required.")
            return
        }
        if (password.length < 6) {
            _authState.value = AuthState.Error("Password must be at least 6 characters.")
            return
        }
        viewModelScope.launch {
            _authState.value = AuthState.Loading
            userRepo.signUpWithEmailPassword(email, password, name)
                .onSuccess { _authState.value = AuthState.Success(it) }
                .onFailure { _authState.value = AuthState.Error("Sign-up failed: ${it.message}") }
        }
    }

    fun continueAsGuest() {
        viewModelScope.launch {
            _authState.value = AuthState.Loading
            userRepo.signInAsGuest()
                .onSuccess { _authState.value = AuthState.Success(it) }
                .onFailure { _authState.value = AuthState.Error("Could not continue as guest.") }
        }
    }

    fun reset() { _authState.value = AuthState.Idle }
}
