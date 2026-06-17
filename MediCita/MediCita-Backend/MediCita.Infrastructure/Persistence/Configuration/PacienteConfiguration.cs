using MediCita.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MediCita.Infrastructure.Persistence.Configuration
{
    public class PacienteConfiguration : IEntityTypeConfiguration<Paciente>
    {
        public void Configure(EntityTypeBuilder<Paciente> builder)
        {
            builder.ToTable("Pacientes");
            builder.HasKey(p => p.Id);

            builder.Property(p => p.Cedula)
                .IsRequired()
                .HasMaxLength(20);

            builder.HasIndex(p => p.Cedula).IsUnique();

            builder.Property(p => p.FechaNacimiento)
                .IsRequired();

            builder.HasOne(p => p.Usuario)
                .WithOne(u => u.Paciente)
                .HasForeignKey<Paciente>(p => p.UsuarioId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
