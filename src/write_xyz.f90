!----------------------------------------------------------------------!
! write_xyz.f90                                                        !
!                                                                      !
! Module for writing xyz file                                          !
!                                                                      !
! C. D. Woodgate,  Warwick                                        2023 !
!----------------------------------------------------------------------!
module write_xyz

  use kinds
  use shared_data
  use analytics

  implicit none

  contains

  !--------------------------------------------------------------------!
  ! Routine to write xyz file, with option to append configurations in !
  ! a single trajectory file.                                          !
  !                                                                    !
  ! C. D. Woodgate,  Warwick                                      2023 !
  ! L. B. Partay,    Warwick                                      2024 !
  !--------------------------------------------------------------------!
  subroutine xyz_writer(filename, configuration, setup, trajectory)
    ! Simulation setup information
    type(run_params), intent(in) :: setup

    ! Data to write to file
    !integer(int16), dimension(:,:,:,:), allocatable, intent(in) :: configuration
    integer(int16), dimension(:,:,:,:), intent(in) :: configuration

    ! Option to open existing xyz file and append new configuration to the end
    logical, optional :: trajectory

    ! Sizes of grid
    integer, dimension(4) :: grid_sizes

    ! Filename to which to write
    character(len=*), intent(in) :: filename

    integer :: n_particles, i, j, k, l
    logical :: exist
    real(real64), dimension(3) :: pos

    n_particles = total_particle_count(setup, configuration)

    grid_sizes = shape(configuration)

    ! Check if we want to open new xyz, overwrite existing xyz or append existing xyz file
    if (present(trajectory)) then

      if (trajectory) then
        inquire(file=filename, exist=exist)
        if (exist) then
          open(7, file=filename, status="old", position="append", action="write")
        else
          open(7, file=filename, status="new", action="write")
        end if      
      end if

    else ! open xyz (if exists, will ovrewrite)

      open(unit=7, file=filename)

    endif  

    write(7, *) n_particles

    if (present(trajectory)) then
      if (trajectory) then
        write(7,*) 'Lattice="',setup%lattice_parameter*setup%n_1, 0.0, 0.0 , &
                       &   0.0, setup%lattice_parameter*setup%n_2, 0.0 , &
                       &   0.0, 0.0, setup%lattice_parameter*setup%n_3,     '"'
      end if          
    else           
      write(7,*) ''
    end if

    do i=1, grid_sizes(1)
      do j=1, grid_sizes(2)
        do k=1, grid_sizes(3)
          do l=1, grid_sizes(4)
            if (configuration(i,j,k,l) .eq. 0) cycle
            pos = real(j-1)*setup%lattice_vectors(1,:) + &
                  real(k-1)*setup%lattice_vectors(2,:) + &
                  real(l-1)*setup%lattice_vectors(3,:) + &
                  real(i)*setup%basis_vectors
            pos = pos*setup%lattice_parameter
            write(7,*) setup%species_names(configuration(i,j,k,l)), pos(1),pos(2),pos(3)
          end do
        end do
      end do
    end do

    close(unit=7)

  end subroutine xyz_writer
   
end module write_xyz
