import 'package:flutter/material.dart';
import 'package:flutter_application_cloudfit/sections/dashboard/models/metric_model.dart';

class MetricCard extends StatelessWidget {
  final MetricModel metric;

  const MetricCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    final change = metric.percentageChange;

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(metric.title),
              const SizedBox(height: 5),
              Text(
                "${metric.value}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${change.toStringAsFixed(1)}%",
                    style: TextStyle(
                      color:
                          metric.isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    metric.isPositive
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 16,
                    color:
                        metric.isPositive ? Colors.green : Colors.red,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}