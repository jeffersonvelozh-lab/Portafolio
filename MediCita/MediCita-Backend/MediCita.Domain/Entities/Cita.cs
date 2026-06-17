namespace MediCita.Domain.Entities
{
    public class Cita
    {
        public int Id { get; set; }
        public Guid CodigoPublico { get; set; }
        public int PacienteId { get; set; }
        public int MedicoId { get; set; }
        public DateTime FechaHora { get; set; }
        public int DuracionMin { get; set; }
        public Enums.EstadoCita Estado { get; set; }
        public string? Motivo { get; set; }
        public string? MotivoCancel { get; set; }
        public DateTime FechaCreacion { get; set; }

        // Navegación
        public Paciente Paciente { get; set; } = null!;
        public Medico Medico { get; set; } = null!;
        public ICollection<Notificacion> Notificaciones { get; set; } = new List<Notificacion>();
    }
}