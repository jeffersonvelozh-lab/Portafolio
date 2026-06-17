namespace MediCita.Domain.Entities
{
    public class Notificacion
    {
        public int Id { get; set; }
        public int CitaId { get; set; }
        public Enums.TipoNotificación Tipo { get; set; }
        public Enums.EstadoNotificación Estado { get; set; }
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaEnvio { get; set; }
        public string? MensajeError { get; set; }

        // Navegación
        public Cita Cita { get; set; } = null!;
    }
}