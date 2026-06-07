import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

const errorRate    = new Rate('error_rate');
const apiDuration  = new Trend('api_duration', true);
const requestCount = new Counter('request_count');

export const options = {
  stages: [
    { duration: '1m', target: 10 },
    { duration: '2m', target: 30 },
    { duration: '3m', target: 50 },
    { duration: '2m', target: 100 },
    { duration: '2m', target: 0 },
  ],

  thresholds: {
    http_req_duration: [
      'p(50)<200',   // Median under 200ms
      'p(95)<500',   // 95th percentile under 500ms
      'p(99)<1000',  // 99th percentile under 1s
    ],
    error_rate: ['rate<0.01'],   // Less than 1% errors
    http_req_failed: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

export default function () {
  group('Health check', () => {
    const res = http.get(`${BASE_URL}/health`, {
      tags: { endpoint: 'health' },
    });

    const ok = check(res, {
      'health status 200': (r) => r.status === 200,
      'health response < 200ms': (r) => r.timings.duration < 200,
      'health body has status':  (r) => r.json('status') === 'healthy',
    });

    errorRate.add(!ok);
    apiDuration.add(res.timings.duration);
    requestCount.add(1);
  });

  group('App endpoints', () => {
    const res = http.get(`${BASE_URL}/`, {
      tags: { endpoint: 'root' },
    });

    check(res, {
      'root status 200': (r) => r.status === 200,
    });

    requestCount.add(1);
  });

  sleep(Math.random() * 2 + 0.5);
}

export function handleSummary(data) {
  return {
    'load-testing/summary.json': JSON.stringify(data, null, 2),
    stdout: `
╔══════════════════════════════════════════════════════╗
║           NEXUS PLATFORM — LOAD TEST RESULTS         ║
╠══════════════════════════════════════════════════════╣
║  Total requests:  ${data.metrics.http_reqs.values.count}
║  Error rate:      ${(data.metrics.http_req_failed.values.rate * 100).toFixed(2)}%
║  p50 latency:     ${data.metrics.http_req_duration.values['p(50)'].toFixed(0)}ms
║  p95 latency:     ${data.metrics.http_req_duration.values['p(95)'].toFixed(0)}ms
║  p99 latency:     ${data.metrics.http_req_duration.values['p(99)'].toFixed(0)}ms
╚══════════════════════════════════════════════════════╝
    `,
  };
}
