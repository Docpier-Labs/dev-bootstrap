#!/usr/bin/env node
import { Command } from 'commander';
import sync from './commands/sync';
import ctx from './commands/ctx';
import deploy from './commands/deploy';
import logs from './commands/logs';
import restart from './commands/restart';
import docker from './commands/docker';

const program = new Command();

program.name('dp').description('Engineering CLI').version('1.0.0');

program.command('sync').description('Sync all repos').action(sync);
program.command('ctx').description('Switch Kube context').action(ctx);
program.command('deploy').description('Deploy local env').argument('<env>').action(deploy);
program.command('logs').description('Show logs from service').argument('<service>').action(logs);
program.command('restart').description('Restart a service').argument('<service>').action(restart);
program.command('docker').description('Build/push Docker image').argument('<service>').action(docker);

program.parse();
