package taskmanager.backend.services.impl

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import org.bson.types.ObjectId
import taskmanager.backend.plugins.exceptions.custom.InternalServerException
import taskmanager.backend.services.AuthService
import taskmanager.backend.shared.Configuration
import java.time.Duration
import java.util.*

class AuthServiceImpl(private val configuration: Configuration) : AuthService {

    override fun generateToken(id: ObjectId, email: String): String {
        return JWT.create()
            .withIssuer(configuration.jwtIssuer)
            .withClaim("_id", id.toString())
            .withClaim("email", email)
            .withExpiresAt(Date(System.currentTimeMillis() + Duration.ofDays(1).toMillis()))
            .sign(Algorithm.HMAC256(configuration.jwtSecret))
            ?: throw InternalServerException("Ошибка генерации токена")
    }
}