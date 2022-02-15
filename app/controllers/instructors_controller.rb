class InstructorsController < ApplicationController
  before_action :set_instructor, only: %i[ show edit update destroy ]
  before_action :correct_student?
  before_action :correct_instructor?

  # GET /instructors or /instructors.json
  def index
    @instructors = Instructor.all
  end

  # GET /instructors/1 or /instructors/1.json
  def show
  end

  # GET /instructors/new
  def new
    @instructor = Instructor.new
  end

  # GET /instructors/1/edit
  def edit
  end

  # POST /instructors or /instructors.json
  def create
    user = User.create!(:name => params['instructor']['name'],:email => params['instructor']["email"], :password => "defaultpassword",:user_type => "Instructor")
    @instructor = Instructor.new(instructor_params)
    @instructor.user_id = user.id

    respond_to do |format|
      if @instructor.save
        format.html { redirect_to instructor_url(@instructor), notice: "Instructor was successfully created." }
        format.json { render :show, status: :created, location: @instructor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instructors/1 or /instructors/1.json
  def update
    respond_to do |format|
      if @instructor.update(instructor_params)
        if is_admin?
          @instructor.user.update!(:name => params[:instructor][:name], :email =>  params[:instructor][:email])
        end
        format.html { redirect_to instructor_url(@instructor), notice: "Instructor was successfully updated." }
        format.json { render :show, status: :ok, location: @instructor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  def correct_student?
    @student = Student.find_by user_id: current_user.id
    if !@student.nil?
       flash[:alert] = "Not authorised to perform this action"
       redirect_to courses_path
    end
  end

  def correct_instructor?
    if is_instructor?
      @cur_instructor = Instructor.find_by user_id: current_user.id
      if !@cur_instructor.nil? && @instructor.id!=@cur_instructor.id
        flash[:alert] = "Not authorised to perform this action"
        redirect_to courses_path
      end
    end
  end

  # DELETE /instructors/1 or /instructors/1.json
  def destroy
    user = User.find(@instructor.user.id)
    @instructor.destroy
    user.destroy
    respond_to do |format|
      format.html { redirect_to instructors_url, notice: "Instructor was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_instructor
      @instructor = Instructor.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def instructor_params
      params.require(:instructor).permit(:department, :user_id)
    end
end
