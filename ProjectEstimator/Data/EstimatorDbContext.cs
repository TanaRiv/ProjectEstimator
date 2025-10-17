using Microsoft.EntityFrameworkCore;
using ProjectEstimator.Models;
using System.Text.Json;

namespace ProjectEstimator.Data
{
    public class EstimatorDbContext : DbContext
    {
        public EstimatorDbContext(DbContextOptions<EstimatorDbContext> options)
            : base(options)
        {
        }

        public DbSet<ProjectEstimation> Estimations { get; set; }
        public DbSet<DevelopmentTask> Tasks { get; set; }
        public DbSet<EstimationFeedback> Feedbacks { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<ProjectEstimation>()
                .HasMany(e => e.Tasks)
                .WithOne()
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<EstimationFeedback>()
                .HasMany(f => f.TaskFeedbacks)
                .WithOne()
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<DevelopmentTask>()
                .Property(t => t.Category)
                .HasConversion<string>();

            modelBuilder.Entity<DevelopmentTask>()
                .Property(t => t.Complexity)
                .HasConversion<string>();

            modelBuilder.Entity<ProjectEstimation>()
                .Property(e => e.Status)
                .HasConversion<string>();

            modelBuilder.Entity<DevelopmentTask>()
                .Property(t => t.Dependencies)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                    v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>());

            modelBuilder.Entity<DevelopmentTask>()
                .Property(t => t.RequiredSkills)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                    v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>());
        }
    }
}
