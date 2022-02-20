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
    @student = Student.new(student_params)
    if is_student?
      @student.user_id = current_user.id
    else
      user = User.create!(:name => params['student']['name'],:email => params['student']["email"], :password => "defaultpassword",:user_type => "Student")
      @student.user_id = user.id
    end

    respond_to do |format|
      if @student.save
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
      if @student.update(student_params) 
        if is_admin?
          @student.user.update!(:name => params[:student][:name], :email =>  params[:student][:email])
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

  def deny_access
    if (action_name == "new" || action_name == "create") && !Student.exists?(user_id:current_user.id)
      return
    elsif !is_admin?
      flash[:alert] = "Not authorised to perform this action"
      redirect_to root_path
    end
  end

  def correct_student?
    @cur_student = Student.find_by user_id: current_user.id
    if !@cur_student.nil? && @student.id!=@cur_student.id
       flash[:alert] = "Not authorised to perform this action"
       redirect_to root_path
    end
  end

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
