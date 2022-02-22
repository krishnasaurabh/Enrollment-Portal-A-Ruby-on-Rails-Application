class StudentsController < ApplicationController
  before_action :set_student, only: %i[ show edit update destroy ]
  skip_before_action :check_student_instructor_registered, only: %i[new create]
  before_action :deny_access, only: %i[ destroy new create index ]
  before_action :correct_student?, only: %i[ edit update show]
  before_action :correct_instructor?

  # GET /students or /students.json
  def index
    @students = Student.all
  end

  # GET /students/1 or /students/1.json
  def show
  end

  # GET /students/new
  def new
    @is_new = true
    @user = User.new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit
  end

  # POST /students or /students.json
  def create
    users_errors = false
    create_successful = false
    user = ''
    @student = Student.new(student_params)
    if is_student?
      @student.user_id = current_user.id
      begin
        ActiveRecord::Base.transaction do
          @student.save!
          create_successful = true
        end
      rescue ActiveRecord::RecordInvalid => invalid
        p "why me?"
      end
    else
      begin
        user = User.new(:name => params['student']['name'],:email => params['student']["email"], :password => "defaultpassword",:user_type => "Student")
        @username =  params['student']['name']
        @useremail = params['student']["email"]
        ActiveRecord::Base.transaction do
          user.save!
          @student.user_id = user.id
          @student.save!
          create_successful = true
        end
      rescue ActiveRecord::RecordInvalid => invalid
        if user.errors[:name].any?
          @student.errors.add(:name, user.errors[:name][0])
        end
    
        if user.errors[:email].any?
          @student.errors.add(:email, user.errors[:email][0])
        end
      end
    end

    respond_to do |format|
      if create_successful
        format.html { redirect_to student_url(@student), notice: "Student was successfully created." }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1 or /students/1.json
  def update
    respond_to do |format|
      update_successful = false
      if is_admin?
        begin
          ActiveRecord::Base.transaction do
            @student.update!(student_params) 
            @student.user.update!(:name => params[:student][:name], :email =>  params[:student][:email])
            update_successful = true
          end
        rescue ActiveRecord::RecordInvalid => invalid
          if @student.user.errors[:name].any?
            @student.errors.add(:name, @student.user.errors[:name][0])
          end
      
          if @student.user.errors[:email].any?
            @student.errors.add(:email, @student.user.errors[:email][0])
          end
        end
      else
        begin
          ActiveRecord::Base.transaction do
            @student.update!(student_params) 
            update_successful = true
          end
        rescue ActiveRecord::RecordInvalid => invalid
          p "failed"
        end
      end

      if update_successful 
        if is_admin?
          
          format.html { redirect_to student_url(@student), notice: "Student was successfully updated." }
        else
          format.html { redirect_to root_path, notice: "Student was successfully updated." }
        end
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1 or /students/1.json
  def destroy
    user = User.find(@student.user.id)
    @student.destroy
    user.destroy
    fill_enrollments_with_waitlist
    respond_to do |format|
      format.html { redirect_to students_url, notice: "Student was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  #deny access to all the users unless admin
  def deny_access
    if (action_name == "new" || action_name == "create") && !Student.exists?(user_id:current_user.id)
      return
    elsif !is_admin?
      flash[:alert] = "Not authorised to perform this action"
      redirect_to root_path
    end
  end

  #check if the student making the update is a correct student or not
  def correct_student?
    @cur_student = Student.find_by user_id: current_user.id
    if !@cur_student.nil? && @student.id!=@cur_student.id
       flash[:alert] = "Not authorised to perform this action"
       redirect_to root_path
    end
  end

  #check if the instructor making the update is a correct student or not
  def correct_instructor?
    if is_instructor?
      @instructor = Instructor.find_by user_id: current_user.id
      if !@instructor.nil? 
        flash[:alert] = "Not authorised to perform this action"
        redirect_to root_path
      end
    end
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def student_params
      params.require(:student).permit(:date_of_birth, :phone_number, :major, :user_id)
    end
end
