package taskmanager.backend.models

import at.favre.lib.crypto.bcrypt.BCrypt
import org.koin.java.KoinJavaComponent.inject
import taskmanager.backend.dtos.response.UserResponseDto
import taskmanager.backend.models.base.impl.BaseEntityImpl
import taskmanager.backend.services.S3Service
import taskmanager.backend.shared.Configuration

data class User(
    var email: String,
    var password: String,
    var firstName: String,
    var lastName: String,
    var picturePath: String? = null,
) : BaseEntityImpl() {

    fun hashPassword(): User {
        password = Companion.hashPassword(password)
        return this
    }

    fun comparePassword(checkedPassword: String): Boolean {
        return BCrypt.verifyer().verify(checkedPassword.toCharArray(), password).verified
    }

    fun getProfilePicturePath(): String {
        return "/users/pictures/${_id}.png"
    }

    fun toResponseDto(): UserResponseDto {
        return UserResponseDto(
            _id = _id.toString(),
            email = email,
            firstName = firstName,
            lastName = lastName,
            profilePicture = s3Service.getUrlOrNull(picturePath)
        )
    }

    companion object {

        private val configuration by inject<Configuration>(Configuration::class.java)
        private val s3Service by inject<S3Service>(S3Service::class.java)

        fun hashPassword(password: String): String {
            return BCrypt
                .withDefaults()
                .hashToString(configuration.bcryptStrength, password.toCharArray())
        }
    }
}