# Final steps and success message

# Run migrations
rails_command "db:migrate"

# Seed the database
rails_command "db:seed"

# Run RuboCop autocorrect
run "bundle exec rubocop -A"

# Initialize git repository
git :init
git add: "."
git commit: "-m 'Initial commit from Rails template with all features'"

# Final success message
say "✓ Template applied successfully!", :green
say ""
say "=== Next Steps ===", :yellow
say ""
say "1. Start your development server:", :cyan
say "   foreman start -f Procfile.dev", :white
say ""
say "2. Visit your application:", :cyan
say "   http://localhost:3000", :white
say ""
say "3. Sign in with:", :cyan
say "   Admin: admin@example.com / password", :white
say "   User:  user@example.com / password", :white
say ""
say "4. Check background jobs:", :cyan
say "   http://localhost:3000/jobs", :white
say ""
say "5. Email previews (letter_opener):", :cyan
say "   Check tmp/letter_opener/ or browser will auto-open", :white
say ""
say "6. Admin panel:", :cyan
say "   http://localhost:3000/admin (admin only)", :white
say ""
say "=== Features Included ===", :green
say "✓ Session-based authentication", :white
say "✓ Role-based authorization (user, admin)", :white
say "✓ Admin panel for user management", :white
say "✓ Email notifications (welcome emails)", :white
say "✓ Background jobs (Solid Queue)", :white
say "✓ MVP.css + SMACSS structure", :white
say "✓ RuboCop configuration", :white
say "✓ Lefthook git hooks", :white
say "✓ Kamal deployment ready", :white
say "✓ agents.md for AI assistance", :white
say "✓ Enhanced test helpers", :white
say ""
