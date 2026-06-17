namespace MediCita.Domain.Entities
{
    public class Medico
    {
        public int Id { get; set; }
        public int UsuarioId { get; set; }
        public int EspecialidadId { get; set; }
        public string NumLicencia { get; set; } = string.Empty;

        // Navegación
        public Usuario Usuario { get; set; } = null!;
        public Especialidad Especialidad { get; set; } = null!;
        public ICollection<HorarioMedico> Horarios { get; set; } = new List<HorarioMedico>();
        public ICollection<Cita> Citas { get; set; } = new List<Cita>();
    }
}