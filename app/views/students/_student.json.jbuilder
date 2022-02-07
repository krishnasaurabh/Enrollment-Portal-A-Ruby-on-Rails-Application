json.extract! student, :id, :date_of_birth, :phone_number, :major, :created_at, :updated_at
json.url student_url(student, format: :json)
