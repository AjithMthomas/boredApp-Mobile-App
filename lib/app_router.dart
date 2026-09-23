import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'state/providers.dart';
import 'ui/screens/activity/activity_screen.dart';
import 'ui/screens/activity/my_applications_screen.dart';
import 'ui/screens/activity/my_posts_screen.dart';
import 'ui/screens/auctions/auction_detail_screen.dart';
import 'ui/screens/auctions/auctions_screen.dart';
import 'ui/screens/auctions/create_auction_screen.dart';
import 'ui/screens/auth/email_screen.dart';

import 'ui/screens/auth/intent_screen.dart';
import 'ui/screens/auth/otp_screen.dart';
import 'ui/screens/auth/profile_setup_screen.dart';
import 'ui/screens/chat/chat_room_screen.dart';
import 'ui/screens/chat/messages_screen.dart';
import 'ui/screens/community/community_board_screen.dart';
import 'ui/screens/create/create_screen.dart';
import 'ui/screens/create/create_wizard_screen.dart';
import 'ui/screens/discover/discover_screen.dart';
import 'ui/screens/discover/task_detail_screen.dart';
import 'ui/screens/emergency/emergency_hub_screen.dart';
import 'ui/screens/hubs/gigs_and_rooms_screens.dart';
import 'ui/screens/hubs/team_hub_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/lifecycle/completion_screen.dart';
import 'ui/screens/lifecycle/session_screen.dart';
import 'ui/screens/misc/notifications_screen.dart';
import 'ui/screens/misc/report_screen.dart';
import 'ui/screens/play/play_and_perks_screens.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'ui/screens/onboarding/splash_screen.dart';
import 'ui/screens/onboarding/welcome_screen.dart';
import 'ui/screens/radar/radar_map_screen.dart';
import 'ui/screens/profile/profile_screen.dart';
import 'ui/screens/safety/safety_center_screen.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final backend = ref.read(storeProvider).backend;

  return GoRouter(
    refreshListenable: backend,
    initialLocation: '/',
    redirect: (context, state) {
      final b = backend;
      final loc = state.matchedLocation;
      const preAuth = {'/', '/auth/email', '/auth/otp'};
      const onboarding = {'/auth/intent', '/auth/profile'};

      // Not signed in: only splash/email/otp are reachable.
      if (!b.signedIn) {
        return preAuth.contains(loc) ? null : '/auth/email';
      }

      // Signed in but profile incomplete: stay in onboarding chain.
      if (b.signupName.isEmpty) {
        return onboarding.contains(loc) ? null : '/auth/intent';
      }

      // Fully signed in: keep out of auth/onboarding screens.
      if (preAuth.contains(loc) || onboarding.contains(loc)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/email',
        builder: (context, state) => const EmailScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/auth/intent',
        builder: (context, state) => const IntentScreen(),
      ),
      GoRoute(
        path: '/auth/profile',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // ── Shell (bottom nav) ─────────────────────────────────────
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shell'),
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(
              path: '/discover',
              builder: (_, _) => const DiscoverScreen()),
          GoRoute(
              path: '/activity',
              builder: (_, _) => const ActivityScreen()),
          GoRoute(
            path: '/activity/my-posts',
            builder: (_, _) => const MyPostsScreen(),
          ),
          GoRoute(
            path: '/activity/my-applications',
            builder: (_, _) => const MyApplicationsScreen(),
          ),
          GoRoute(
              path: '/messages',
              builder: (_, _) => const MessagesScreen()),
        ],
      ),

      // ── Stack screens ──────────────────────────────────────────
      GoRoute(
        path: '/task/:id',
        builder: (_, state) =>
            TaskDetailScreen(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/task/:id/session',
        builder: (_, state) =>
            SessionScreen(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/task/:id/complete',
        builder: (_, state) =>
            CompletionScreen(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat/:appId',
        builder: (_, state) =>
            ChatRoomScreen(applicationId: state.pathParameters['appId']!),
      ),
      GoRoute(path: '/create', builder: (_, _) => const CreateScreen()),
      GoRoute(
        path: '/create/wizard',
        builder: (_, _) => const CreateWizardScreen(),
      ),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(
          path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(
          path: '/safety',
          builder: (_, _) => const SafetyCenterScreen()),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/report/:taskId',
        builder: (_, state) =>
            ReportScreen(taskId: state.pathParameters['taskId']!),
      ),
      GoRoute(
        path: '/auctions',
        builder: (_, _) => const AuctionsScreen(),
      ),
      GoRoute(
        path: '/auction/:id',
        builder: (_, state) =>
            AuctionDetailScreen(auctionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/auctions/create',
        builder: (_, _) => const CreateAuctionScreen(),
      ),
      GoRoute(
        path: '/emergency',
        builder: (_, state) => EmergencyHubScreen(
          autoOpenCreate:
              state.uri.queryParameters['create'] == '1',
        ),
      ),
      GoRoute(
        path: '/gigs',
        builder: (_, state) => GigsHubScreen(
          autoOpenCreate:
              state.uri.queryParameters['create'] == '1',
        ),
      ),
      GoRoute(
        path: '/rooms',
        builder: (_, state) => RoomFinderScreen(
          autoOpenCreate:
              state.uri.queryParameters['create'] == '1',
        ),
      ),
      GoRoute(
        path: '/team',
        builder: (_, state) => TeamHubScreen(
          autoOpenCreate:
              state.uri.queryParameters['create'] == '1',
        ),
      ),
      GoRoute(path: '/play', builder: (_, _) => const PlayEarnScreen()),
      GoRoute(
          path: '/perks', builder: (_, _) => const PartnerPerksScreen()),      GoRoute(
        path: '/community',
        builder: (_, _) => const CommunityBoardScreen()),
      GoRoute(
        path: '/radar',
        builder: (_, _) => const RadarMapScreen(),
      ),
    ],
  );
});

