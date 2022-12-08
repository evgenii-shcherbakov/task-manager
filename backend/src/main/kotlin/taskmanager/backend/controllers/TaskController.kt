package taskmanager.backend.controllers

import com.github.iipekolict.knest.annotations.classes.Controller
import com.github.iipekolict.knest.annotations.methods.*
import com.github.iipekolict.knest.annotations.properties.Body
import com.github.iipekolict.knest.annotations.properties.File
import com.github.iipekolict.knest.annotations.properties.Param
import io.ktor.http.content.*
import io.ktor.server.application.*
import io.ktor.server.plugins.*
import io.ktor.server.response.*
import org.bson.types.ObjectId
import taskmanager.backend.dtos.request.*
import taskmanager.backend.dtos.response.AttachmentResponseDto
import taskmanager.backend.dtos.response.CommentResponseDto
import taskmanager.backend.dtos.response.NoteResponseDto
import taskmanager.backend.dtos.response.TaskResponseDto
import taskmanager.backend.enums.EditableEntity
import taskmanager.backend.enums.Priority
import taskmanager.backend.enums.Status
import taskmanager.backend.mappers.CommentMapper
import taskmanager.backend.mappers.NoteMapper
import taskmanager.backend.mappers.TaskMapper
import taskmanager.backend.plugins.annotations.JwtUser
import taskmanager.backend.models.*
import taskmanager.backend.plugins.annotations.EditAccess
import taskmanager.backend.services.*

@Controller("tasks")
class TaskController(
    private val taskService: TaskService,
    private val workService: WorkService,
    private val commentService: CommentService,
    private val noteService: NoteService,
    private val attachmentService: AttachmentService,
    private val fileService: FileService,
    private val s3Service: S3Service,
    private val taskMapper: TaskMapper,
    private val noteMapper: NoteMapper,
    private val commentMapper: CommentMapper
) {

    @Get("{id}")
    @Authentication(["auth-jwt"])
    suspend fun getById(@JwtUser user: User, @Param("id") id: String): TaskResponseDto {
        return taskMapper.convert(
            userId = user._id,
            task = taskService.getById(ObjectId(id))
        )
    }

    @Get("{id}/works")
    @Authentication(["auth-jwt"])
    suspend fun getTaskWorks(@Param("id") id: String): List<Work> {
        return workService.getByTask(ObjectId(id))
    }

    @Get("{id}/comments")
    @Authentication(["auth-jwt"])
    suspend fun getTaskComments(
        @JwtUser user: User,
        @Param("id") id: String
    ): List<CommentResponseDto> {
        return commentMapper.convert(
            userId = user._id,
            comments = commentService.getByTask(ObjectId(id))
        )
    }

    @Get("{id}/notes")
    @Authentication(["auth-jwt"])
    suspend fun getTaskNotes(
        @JwtUser user: User,
        @Param("id") id: String
    ): List<NoteResponseDto> {
        return noteMapper.convert(
            userId = user._id,
            notes = noteService.getByTask(ObjectId(id))
        )
    }

    @Get("{id}/attachments")
    @Authentication(["auth-jwt"])
    suspend fun getTaskAttachments(
        @JwtUser user: User,
        @Param("id") id: String
    ): List<AttachmentResponseDto> {
        return attachmentService.getByTask(ObjectId(id)).map { it.toResponseDto(user._id) }
    }

    @Get("{id}/blocked-by")
    @Authentication(["auth-jwt"])
    suspend fun getAllowedBlockedByForTask(
        @JwtUser user: User,
        @Param("id") id: String
    ): List<TaskResponseDto> {
        return taskMapper.convert(
            userId = user._id,
            tasks = taskService.getAllowedBlockedBy(taskService.getById(ObjectId(id)))
        )
    }

    @Post("{id}/works")
    @Authentication(["auth-jwt"])
    suspend fun createTaskWork(
        @JwtUser user: User,
        @Param("id") id: String,
        @Body(type = WorkDto::class) dto: WorkDto
    ): Work {
        return workService.create(user._id, ObjectId(id), dto)
    }

    @Post("{id}/comments")
    @Authentication(["auth-jwt"])
    suspend fun createTaskComment(
        @JwtUser user: User,
        @Param("id") id: String,
        @Body("text") text: String
    ): CommentResponseDto {
        return commentMapper.convert(
            userId = user._id,
            comment = commentService.create(user._id, ObjectId(id), text)
        )
    }

    @Post("{id}/notes")
    @Authentication(["auth-jwt"])
    suspend fun createTaskNote(
        @JwtUser user: User,
        @Param("id") id: String,
        @Body(type = NoteDto::class) dto: NoteDto
    ): NoteResponseDto {
        return noteMapper.convert(
            userId = user._id,
            note = noteService.create(user._id, ObjectId(id), dto)
        )
    }

    @Post("{id}/attachments")
    @Authentication(["auth-jwt"])
    suspend fun createTaskAttachment(
        @JwtUser user: User,
        @Param("id") id: String,
        @File("file") file: PartData.FileItem?
    ): AttachmentResponseDto {
        if (file == null) throw BadRequestException("Нет файла вложения")

        val attachmentId = ObjectId()
        val path = "/tasks/$id/attachments/$attachmentId"

        s3Service.save(
            path = path,
            content = fileService.convertFileItemToByteArray(file)
        )

        val dto = CreateAttachmentDto(
            name = file.originalFileName ?: "(без имени)",
            type = file.contentType?.contentType?.uppercase() ?: "TEXT",
            path = path
        )

        return attachmentService.create(user._id, ObjectId(id), dto).toResponseDto(user._id)
    }

    @Patch("{id}/info")
    @Authentication(["auth-jwt"])
    suspend fun updateInfo(
        @JwtUser user: User,
        @Param("id") id: String,
        @Body(type = UpdateTaskInfoDto::class) dto: UpdateTaskInfoDto
    ): TaskResponseDto {
        return taskMapper.convert(
            userId = user._id,
            task = taskService.updateInfo(ObjectId(id), dto)
        )
    }

    @Patch("{id}/assigned-to")
    @Authentication(["auth-jwt"])
    suspend fun updateAssignedTo(
        @JwtUser user: User,
        @Param("id") id: String,
        @Body("assignedTo") assignedTo: String
    ): TaskResponseDto {
        return taskMapper.convert(
            userId = user._id,
            task = taskService.updateAssignedTo(ObjectId(id), ObjectId(assignedTo))
        )
    }

    @Patch("{id}/status")
    @Authentication(["auth-jwt"])
    suspend fun updateStatus(
        @JwtUser user: User,
        @Param("id") id: String,
        @Body("status") status: String
    ): TaskResponseDto {
        return taskMapper.convert(
            userId = user._id,
            task = taskService.updateStatus(ObjectId(id), Status.valueOf(status))
        )
    }

    @Patch("{id}/priority")
    @Authentication(["auth-jwt"])
    suspend fun updatePriority(
        @JwtUser user: User,
        @Param("id") id: String,
        @Body("priority") priority: String
    ): TaskResponseDto {
        return taskMapper.convert(
            userId = user._id,
            task = taskService.updatePriority(ObjectId(id), Priority.valueOf(priority))
        )
    }

    @Patch("{id}/tags")
    @Authentication(["auth-jwt"])
    suspend fun updateTags(
        @JwtUser user: User,
        @Param("id") id: String,
        @Body("tags") tags: List<String>
    ): TaskResponseDto {
        return taskMapper.convert(
            userId = user._id,
            task = taskService.updateTags(ObjectId(id), tags.map { ObjectId(it) })
        )
    }

    @Patch("{id}/blocked-by")
    @Authentication(["auth-jwt"])
    suspend fun updateBlockedBy(
        @JwtUser user: User,
        @Param("id") id: String,
        @Body("blockedBy") blockedBy: List<String>
    ): TaskResponseDto {
        return taskMapper.convert(
            userId = user._id,
            task = taskService.updateBlockedBy(ObjectId(id), blockedBy.map { ObjectId(it) })
        )
    }

    @Delete("{id}")
    @Authentication(["auth-jwt"])
    @EditAccess(EditableEntity.TASK, "Вы не можете удалить эту задачу")
    suspend fun deleteById(@Param("id") id: String): DeleteDto {
        return DeleteDto(taskService.deleteById(ObjectId(id)))
    }
}