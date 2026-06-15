import 'package:flutter/material.dart';

import '../../../core/widgets/section_card.dart';

class EmployeeManagementScreen extends StatelessWidget {
  const EmployeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const employees = [
      ('Priya Sharma', 'Sales Lead', '42 scans', 'synced'),
      ('Daniel Reed', 'Partnerships', '31 scans', 'pending'),
      ('Fatima Noor', 'Events', '26 scans', 'synced'),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Employee Management', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Admin invite flow, employee visibility, and activity monitoring live here.'),
          const SizedBox(height: 24),
          SectionCard(
            title: 'Team Accounts',
            trailing: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.person_add_alt_1_rounded), label: const Text('Invite')),
            child: Column(
              children: employees
                  .map(
                    (employee) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text(employee.$1.substring(0, 1))),
                      title: Text(employee.$1),
                      subtitle: Text('${employee.$2} • ${employee.$3}'),
                      trailing: Chip(label: Text(employee.$4)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
