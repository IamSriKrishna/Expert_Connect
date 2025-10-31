import 'package:expert_connect/src/helper/payment_helper.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/home/repo/home_repo.dart';
import 'package:expert_connect/src/models/appointment_type_model.dart';
import 'package:expert_connect/src/profile/bloc/booking_bloc.dart';
import 'package:expert_connect/src/profile/widgets/calendar_widget.dart';
import 'package:expert_connect/src/profile/widgets/vendor_booking_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AppointmentBookingScreen extends StatelessWidget {
  final int id;
  final AppointmentTypeModel appointmentTypeModel;

  const AppointmentBookingScreen({
    super.key,
    required this.id,
    required this.appointmentTypeModel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingBloc(),
      child: _AppointmentBookingContent(
        id: id,
        appointmentTypeModel: appointmentTypeModel,
      ),
    );
  }
}

class _AppointmentBookingContent extends StatefulWidget {
  final int id;
  final AppointmentTypeModel appointmentTypeModel;

  const _AppointmentBookingContent({
    required this.id,
    required this.appointmentTypeModel,
  });

  @override
  State<_AppointmentBookingContent> createState() =>
      _AppointmentBookingContentState();
}

class _AppointmentBookingContentState
    extends State<_AppointmentBookingContent> {
  late HomeBloc _homeBloc;
  DateTime? _lastSelectedDate;

  final TextEditingController description = TextEditingController();
  bool _descriptionError = false;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  @override
  void dispose() {
    _disposeComponents();
    description.dispose(); 
    super.dispose();
  }

  void _initializeComponents() {
    _homeBloc = HomeBloc(HomeRepoImpl());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PaymentHelper.initializeRazorpay(context);
    });
  }

  void _disposeComponents() {
    final bloc = context.read<BookingBloc>();
    bloc.add(const ClearRazorpay());
    _homeBloc.close();
  }

  void _fetchSlotsForDate(DateTime selectedDate) {
    final formattedDate = DateFormat("yyyy-MM-dd").format(selectedDate);
    _homeBloc.add(FetchVendorSlotBooking(id: widget.id, date: formattedDate));
  }

  void _handleDateChangeIfNeeded(BookingState state) {
    if (_lastSelectedDate != state.selectedDate) {
      _lastSelectedDate = state.selectedDate;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchSlotsForDate(state.selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>.value(
      value: _homeBloc,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return BlocListener<BookingBloc, BookingState>(
            listener: PaymentHelper.listener(
              homeState: state,
              description: description.text,
              vendorId: widget.id,
              appointment: widget.appointmentTypeModel,
            ),
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                _handleDateChangeIfNeeded(state);

                return BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, homeState) {
                    return Scaffold(
                      backgroundColor: Colors.grey[50],
                      body: Stack(
                        children: [
                          CustomScrollView(
                            slivers: [
                              VendorBookingWidgets.appBar(context),
                              CalendarWidget.calendarSection(context, state),
                              VendorBookingWidgets.timeSlotSection(
                                homeState,
                                state,
                                context,
                              ),
                              SliverToBoxAdapter(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: TextField(
                                    controller: description,
                                    maxLines: null,
                                    onChanged: (value) {
                                      if (_descriptionError &&
                                          value.trim().isNotEmpty) {
                                        setState(
                                          () => _descriptionError = false,
                                        );
                                      }
                                    },
                                    minLines: 3,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF2D3748),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Description *',
                                      labelStyle: TextStyle(
                                        color: _descriptionError
                                            ? const Color(0xFFE53E3E)
                                            : const Color(0xFF718096),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      hintText:
                                          'Enter your description here...',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFA0AEC0),
                                        fontSize: 16,
                                      ),
                                      errorText: _descriptionError
                                          ? 'Description is required'
                                          : null,
                                      filled: true,
                                      fillColor: const Color(0xFFF7FAFC),
                                      prefixIcon: const Icon(
                                        Icons.description_outlined,
                                        color: Color(0xFF718096),
                                        size: 20,
                                      ),
                                      suffixIcon: const Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF718096),
                                        size: 18,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _descriptionError
                                              ? const Color(0xFFE53E3E)
                                              : const Color(0xFFE2E8F0),
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _descriptionError
                                              ? const Color(0xFFE53E3E)
                                              : const Color(0xFF4299E1),
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE53E3E),
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE53E3E),
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                    cursorColor: const Color(0xFF4299E1),
                                    cursorHeight: 20,
                                    textInputAction: TextInputAction.newline,
                                    keyboardType: TextInputType.multiline,
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 245, 253, 255),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color.fromARGB(255, 215, 246, 254),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        size: 18,
                                        color: Color(0xFF718096),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'This platform connects you with experts but is not responsible for the quality or outcomes of consultations provided.',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF4A5568),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (state.selectedTime != null)
                                VendorBookingWidgets.summaryWidget(
                                  state,
                                  widget.appointmentTypeModel,
                                ),
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    VendorBookingWidgets.bookAppointment(
                                      state,
                                      context,
                                      widget.appointmentTypeModel,
                                      widget.id,
                                      description, // ✅ Pass the controller, not .text
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (homeState.status == HomeStateStatus.loading)
                            VendorBookingWidgets.loading(),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
