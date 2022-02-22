class InstructorsController < ApplicationController
  before_action :set_instructor, only: %i[ show edit update destroy ]
  skip_before_action :check_student_instructor_registered, only: %i[new create]
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
    @is_new = true
    @instructor = Instructor.new
  end

  # GET /instructors/1/edit
  def edit
  end

  # POST /instructors or /instructors.json
  def create
    users_errors = false
    create_successful = false
    user = ''
    @instructor = Instructor.new(instructor_params)
    if is_instructor?
      @instructor.user_id = current_user.id
      # start transaction to create a instructor that can be rolled back if it fails
      begin
        ActiveRecord::Base.transaction do
          @instructor.save!
          create_successful = true
        end
      rescue ActiveRecord::RecordInvalid => invalid
      end
    else
      begin
        user = User.new(:name => params['instructor']['name'],:email => params['instructor']["email"], :password => "defaultpassword",:user_type => "Instructor")
        @username =  params['instructor']['name']
        @useremail = params['instructor']["email"]
        # if admin
        # start transaction to create a instructor that can be rolled back if it fails
        # a user must be created before an instructor can be as instructor has a foriegn key of user
        ActiveRecord::Base.transaction do
          user.save!
          @instructor.user_id = user.id
          @instructor.save!
          create_successful = true
        end
      rescue ActiveRecord::RecordInvalid => invalid
        # add the user errors to the list of errors
        if user.errors[:name].any?
          @instructor.errors.add(:name, user.errors[:name][0])
        end
    
        if user.errors[:email].any?
          @instructor.errors.add(:email, user.errors[:email][0])
        end
      end
    end

    respond_to do |format|
      if create_successful
        format.html { redirect_to instructor_url(@instructor), notice: "instructor was successfully created." }
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
      update_successful = false
      if is_admin?
        begin
          ActiveRecord::Base.transaction do
            @instructor.update!(instructor_params) 
            @instructor.user.update!(:name => params[:instructor][:name], :email =>  params[:instructor][:email])
            update_successful = true
          end
        rescue ActiveRecord::RecordInvalid => invalid
          if @instructor.user.errors[:name].any?
            @instructor.errors.add(:name, @instructor.user.errors[:name][0])
          end
      
          if @instructor.user.errors[:email].any?
            @instructor.errors.add(:email, @instructor.user.errors[:email][0])
          end
        end
      else
        begin
          ActiveRecord::Base.transaction do
            @instructor.update!(instructor_params) 
            update_successful = true
          end
        rescue ActiveRecord::RecordInvalid => invalid
          p "failed"
        end
      end

      if update_successful 
        if is_admin?
          
          format.html { redirect_to instructor_url(@instructor), notice: "instructor was successfully updated." }
        else
          format.html { redirect_to root_path, notice: "instructor was successfully updated." }
        end
        format.json { render :show, status: :ok, location: @instructor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # this defines what methods to be blocked if accessed by the wrong user, i.e  student.
  def correct_student?
    @student = Student.find_by user_id: current_user.id
    if !@student.nil?
       flash[:alert] = "Not authorised to perform this action"
       redirect_to root_path
    end
  end

 # this defines what methods to be blocked if accessed by the wrong user, i.e instructor.
  def correct_instructor?
    if is_instructor?
      if (action_name == "new" || action_name == "create") && !Instructor.exists?(user_id:current_user.id)
          return
      elsif action_name == "index" ||action_name == "new" || action_name == "create"
        redirect_to root_path
        return
      end
      @cur_instructor = Instructor.find_by user_id: current_user.id
      if !@cur_instructor.nil? && @instructor.id!=@cur_instructor.id
        flash[:alert] = "Not authorised to perform this action"
        redirect_to root_path
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
