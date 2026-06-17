using MediCita.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MediCita.Infrastructure.Persistence.Configuration
{
    public class MedicoConfiguration : IEntityTypeConfiguration<Medico>
    {
        public void Configure(EntityTypeBuilder<Medico> builder)
        {
            builder.ToTable("Medicos");
            builder.HasKey(m => m.Id);

            builder.Property(m => m.NumLicencia)
                .IsRequired()
                .HasMaxLength(50);

            builder.HasOne(m => m.Usuario)
                .WithOne(u => u.Medico)
                .HasForeignKey<Medico>(m => m.UsuarioId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(m => m.Especialidad)
                .WithMany(e => e.Medicos)
                .HasForeignKey(m => m.EspecialidadId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
