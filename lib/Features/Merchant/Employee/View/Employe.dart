import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Employee/Controllers/EmployeeController.dart';
import 'package:vclub/Features/Merchant/Employee/View/Widgets/EmpDeleteDialog.dart';
import 'package:vclub/Features/Merchant/Employee/View/Widgets/EmpFormScreen.dart';
import 'package:vclub/Features/Merchant/Employee/View/Widgets/EmployeCard.dart';
import 'package:vclub/Features/Merchant/Employee/View/Widgets/EmptyEmpState.dart';
import 'package:vclub/Features/Merchant/Employee/View/Widgets/ErrorState.dart';
import 'package:vclub/Features/Merchant/Employee/View/Widgets/Header.dart';
import 'package:vclub/Features/Merchant/Employee/View/Widgets/ShimmerLoading.dart';

class Employe extends StatefulWidget {
  const Employe({super.key});

  @override
  State<Employe> createState() => _EmployeState();
}

class _EmployeState extends State<Employe> {
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  final EmployeeController controller = Get.put(EmployeeController());

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    // Fixed height for the list area — tweak the factor as needed
    final listHeight = size.height * 0.58;

    return KeyboardDismissOnTap(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.01),

                Align(
                  alignment: isRTL
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: FadeSlide(
                    delayMs: 200,
                    child: AppText(
                      "employees",
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.01),

                Align(
                  alignment: isRTL
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: FadeSlide(
                    delayMs: 250,
                    child: AppText(
                      'employees_subtitle',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                FadeSlide(
                  delayMs: 300,
                  child: EmployeesHeader(
                    searchController: searchController,
                    onAdd: () {
                      AppNavigator.to(EmployeeFormScreen(isEdit: false));
                    },
                    onChanged: controller.onSearchChanged,
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                // ── Fixed-height list area with its own refresh + scroll ──
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const EmployeeShimmerList();
                    }

                    if (controller.hasError.value) {
                      return Center(
                        child: EmployeeErrorState(onRetry: controller.refresh),
                      );
                    }

                    if (controller.employees.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: controller.refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          children: [
                            SizedBox(
                              height: listHeight * 0.9,
                              child: Center(
                                child: EmployeeEmptyState(
                                  isSearching:
                                      controller.searchQuery.value.isNotEmpty,
                                  onAdd: () {
                                    AppNavigator.to(
                                      EmployeeFormScreen(isEdit: false),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return FadeSlide(
                      delayMs: 300,
                      child: RefreshIndicator(
                        onRefresh: controller.refresh,
                        child: ListView.builder(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          // +1 for the "load more" / trailing spacer footer
                          itemCount: controller.employees.length + 1,
                          padding: const EdgeInsets.only(bottom: 8),
                          itemBuilder: (context, index) {
                            if (index == controller.employees.length) {
                              return Obx(() {
                                if (controller.isLoadingMore.value) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                // Extra breathing room after the last card
                                return const SizedBox(height: 60);
                              });
                            }

                            final e = controller.employees[index];
                            return EmployeeCard(
                              employee: e,
                              onEdit: () {
                                AppNavigator.to(
                                  EmployeeFormScreen(isEdit: true, employee: e),
                                );
                              },
                              onDelete: () {
                                EmployeeDeleteDialog.show(
                                  employeeId: e.id,
                                  employeeName: "${e.firstName} ${e.lastName}",
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
