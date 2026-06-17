using MediCita.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace MediCita.Infrastructure.Persistence
{
    public class MediCitaDbContext : DbContext
    {
        public MediCitaDbContext(DbContextOptions<MediCitaDbContext> options) : base(options) { }

        public DbSet<Usuario> Usuarios { get; set; }
        public DbSet<Especialidad> Especialidades { get; set; }
        public DbSet<Medico> Medicos { get; set; }
        public DbSet<Paciente> Pacientes { get; set; }
        public DbSet<HorarioMedico> HorariosMedico { get; set; }
        public DbSet<Cita> Citas { get; set; }
        public DbSet<Notificacion> Notificaciones { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(MediCitaDbContext).Assembly);
            base.OnModelCreating(modelBuilder);
        }
    }
}
