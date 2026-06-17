using MediCita.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MediCita.Infrastructure.Persistence.Configuration
{
    public class UsuarioConfiguration : IEntityTypeConfiguration<Usuario>
    {
        public void Configure(EntityTypeBuilder<Usuario> builder)
        {
            builder.ToTable("Usuarios");
            builder.HasKey(u => u.Id);

            builder.Property(u => u.CodigoPublico)
                .IsRequired()
                .HasDefaultValueSql("NEWSEQUENTIALID()");

            builder.Property(u => u.Nombre)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(u => u.Apellido)
            .IsRequired()
            .HasMaxLength(100);

            builder.Property(u => u.Email)
                .IsRequired()
                .HasMaxLength(150);

            builder.HasIndex(u => u.Email).IsUnique();

            builder.Property(u => u.PasswordHash)
                .IsRequired();

            builder.Property(u => u.Rol)
                .IsRequired()
                .HasConversion<int>();

            builder.Property(u => u.Activo)
            .IsRequired()
            .HasDefaultValue(true);

            builder.Property(u => u.FechaCreacion)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

        }
    }
}
