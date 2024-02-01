import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_clone/configuration/sharepref.dart';
import 'package:github_clone/features/home/model/org_list_model.dart';
import 'package:github_clone/features/home/provider/org_list_provider.dart';
import 'package:github_clone/features/home/provider/repo_list_provider.dart';
import 'package:github_clone/features/home/widgets/cus_leading.dart';
import 'package:github_clone/splash_screen.dart';
import 'package:github_clone/utils/custom_snackbar.dart';
import 'package:github_clone/utils/error_widget.dart';
import 'package:github_clone/utils/loading.dart';
import '../../../configuration/app_colors.dart';
import '../../../configuration/app_styles.dart';
import '../../../configuration/applayout.dart';

class DrawerScreen extends ConsumerStatefulWidget {
  final String name;
  final String profilPic;
  final List<OrganisationListModel> data;
  const DrawerScreen({
    super.key,
    required this.name,
    required this.profilPic,
    required this.data,
  });

  @override
  ConsumerState<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends ConsumerState<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedOrg = ref.watch(selectedOrgProvider);
    return SizedBox(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            height: 93,
            width: MediaQuery.of(context).size.width - 82,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 206,
                width: 53,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7)),
                        child: Image.network(
                          widget.profilPic,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.error_outline,
                              size: 30,
                              color: AppColors.white,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: AppStyles(context).titleSmall.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: const Color(0xFFFF9C37),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Text(
                              ref.read(selectedOrgNameProvider),
                              style: AppStyles(context).bodysmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 10,
              );
            },
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              return ListTile(
                tileColor:
                    selectedOrg == index ? const Color(0xFFD3DEFF) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    5,
                  ),
                ),
                onTap: () async {
                  // update the selected Organisation index
                  ref
                      .read(selectedOrgProvider.notifier)
                      .update((state) => index);
                  ref
                      .read(selectedOrgNameProvider.notifier)
                      .update((state) => widget.data[index].login);
                  ref
                      .read(selctedOrgAvatarProvider.notifier)
                      .update((state) => widget.data[index].avatarUrl);
                  ref.invalidate(repoListProvider);
                  log(ref.read(selectedOrgProvider).toString());
                  setState(() {});
                  Navigator.pop(context);
                },
                title: Text(
                  widget.data[index].login,
                  style: AppStyles(context).titleSmall.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                leading: CustomLeading(
                  image: widget.data[index].avatarUrl,
                  networkImage: true,
                ),
              );
            },
          ),
          ListTile(
            onTap: () {
              showModalBottomSheet(
                showDragHandle: true,
                isDismissible: false,
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Logout",
                      style: AppStyles(context).titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                    AppLayout.spaceH10,
                    Text(
                      "Do you want to logout?",
                      style: AppStyles(context).bodysmall,
                    ),
                    AppLayout.spaceH20,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: FilledButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                              AppColors.warning,
                            )),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "No",
                              style: AppStyles(context).titleSmall.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: FilledButton(
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                              Colors.green,
                            )),
                            onPressed: () async {
                              ///Firebase auth signOut
                              await FirebaseAuth.instance.signOut();
                              await Sharedpref.shareClear();
                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SplashScreen(),
                                    ),
                                    (route) => false);
                                toast("Logout successfully");
                              }
                            },
                            child: Text(
                              "Yes",
                              style: AppStyles(context).titleSmall.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        )
                      ],
                    ),
                    AppLayout.spaceH20
                  ],
                ),
              );
            },
            leading: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFEDEDFF),
                  )),
              child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.logout_outlined,
                  )),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
            title: Text(
              "Logout",
              style: AppStyles(context).titleSmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          )
        ],
      ),
    );
  }
}

final selectedOrgProvider = StateProvider<int>((ref) => 0);
final selectedOrgNameProvider = StateProvider((ref) => "");
final selectRepoUrl = StateProvider((ref) => "");
final selctedOrgAvatarProvider = StateProvider((ref) => "");
