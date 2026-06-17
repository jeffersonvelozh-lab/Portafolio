namespace MediCita.Domain.Entities
{
    public class Usuario
    {
        public int Id { get; set; }
        public Guid CodigoPublico { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Apellido { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public Enums.Rol Rol { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }

        // Navegación
        public Medico? Medico { get; set; }
        public Paciente? Paciente { get; set; }
    }
}
