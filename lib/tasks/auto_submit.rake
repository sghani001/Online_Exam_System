rake_namespace :exams do
  desc 'Auto-submit exams that have reached end_time'
  task auto_submit: :environment do
    AutoSubmitExamsJob.perform_now
    puts 'AutoSubmitExamsJob executed.'
  end
end
