namespace MediCita.Domain.Entities
{
    public class Especialidad
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public bool Activa { get; set; }

        // Navegación
        public ICollection<Medico> Medicos { get; set; } = new List<Medico>();
    }
}