package taskmanager.backend.dtos.request

data class CreateUserDto(
    val email: String,
    val password: String,
    val firstName: String,
    val lastName: String,
)
