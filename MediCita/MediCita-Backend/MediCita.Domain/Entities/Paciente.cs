namespace MediCita.Domain.Entities
{
    public class Paciente
    {
        public int Id { get; set; }
        public int UsuarioId { get; set; }
        public string Cedula { get; set; } = string.Empty;
        public DateTime FechaNacimiento { get; set; }

        // Navegación
        public Usuario Usuario { get; set; } = null!;
        public ICollection<Cita> Citas { get; set; } = new List<Cita>();
    }
}